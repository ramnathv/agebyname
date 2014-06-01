#' Predict sex from name
#' 
#' @import dplyr
#' @export
predict_sex <- function(name_){
  tmp <- bnames_name %>%
    filter(name == name_)
  tmp[which.max(tmp$n),]$sex
}

# get_lifetable_year = function(y){
#   lifetables_y = subset(lifetables, x + year == y)
#   years = seq(1900, 2010, 1)
#   ddply(lifetables_y, .(sex), function(d){
#     f = splinefun(d$year, d$lx, method = 'fmm')
#     data.frame(
#       year = years,
#       lx = f(years),
#       sex = d$sex[1]
#     )
#   })
# }

# lifetable_2014 = get_lifetable_year(2014)


make_data <- function(name_, sex_, state_){
  if (is.null(sex_)){
    sex_ = predict_sex(name_)
  }
  bnames2 = if(state_ == "US"){
    bnames
  } else {
    tbl_df(bnames_by_state) %>%
    filter(state == state_)
  }
  babynames_sub = bnames2 %>%
    filter(name == name_, sex == sex_) %>%
    merge(cor_factors, by = 'year') %>%
    merge(lifetable_2014, by = c("year", "sex")) %>%
    mutate(n_cor = n*cor, n_alive = lx/10^5*n_cor)
}


#' Plot graph given name, sex and state
#' 
#' @import ggplot2
#' @importFrom Hmisc wtd.quantile
#' @export
plot_name <- function(name_, sex_ = NULL, state_ = 'US'){
    
  dat = make_data(name_, sex_, state_)
  
  qtls = with(dat, wtd.quantile(year, weights = lx/10^5*n))
  qtls_dat = subset(dat, year %in% qtls[2:4])
  
  #   r1 <- rPlot(n ~ year, data = dat, type = 'line')
  #   r1$layer(y = "n4", color = "qtl", copy_layer = TRUE, type = 'area')
  #   r1$set(width = 700)
  #   r1
  title_ = sprintf("Age Distribution of %s %s named %s",
    state_, 
    ifelse(dat$sex[1] == "M", "Males", "Females"), 
    name_
  )
  ggplot(dat, aes(x = year, y = n_alive)) + 
    geom_area(alpha = 0.3) +
    geom_line(aes(y = n_cor)) +
    geom_segment(aes(x = year, xend = year, y = 0, yend = n_alive), 
      data = qtls_dat, color = 'darkred'
    ) +
    coord_cartesian(xlim = c(1900, 2010)) +
    theme(legend.position = 'none') +
    labs(x = "", y = "") +
    ggtitle(title_) + 
    theme(
      title = element_text(hjust = 0, 
        face = 'bold', size = 16, vjust = 2)
      )
}

#' Estimate age given name, sex and state
#' 
#' @importFrom Hmisc wtd.quantile
#' @export
estimate_age <- function(name_, sex_ = NULL, state_ = 'US'){
  dat = make_data(name_, sex_, state_)
  qtls = with(dat, wtd.quantile(year, weights = lx/10^5*n))
  h = rev(2014 - qtls)
  h2 = data.frame(t(h))
  names(h2) = c(paste0('q', seq(0, 100, by = 25)))
  h2[] = apply(h2, 1, function(x) as.numeric(as.character(x)))
  h2$name = name_
  h2$sex = sex_
  h2$p_alive = with(dat, round(sum(n_alive)/sum(n_cor)*100, 3))
  h2
}
