# Source: www.census.gov/statab/hist/02HS0013.xls
# downloader::download(
#  'http://www.census.gov/statab/hist/02HS0013.xls',
#  'rawdata/02HS0013.xls'
# )
library(gdata)
dat = read.xls(
  'rawdata/02HS0013.xls', sheet = 1, skip = 9,
  stringsAsFactors = F
)
tot_births = dat[1:102,1:2]
names(tot_births) = c('year', 'births')

tot_births$births = as.numeric(gsub(',', "", tot_births$births))
tot_births$year = as.numeric(tot_births$year)

library(dplyr)
cor_factors = bnames %>%
  group_by(year) %>%
  summarize(n = sum(n)) %>%
  inner_join(tot_births) %>%
  mutate(cor = as.numeric(births)*1000/n) %>%
  select(year, cor)

cor_factors[1:9,'cor'] = cor_factors[10,'cor']
cor_factors = rbind(
  cor_factors,
  data.frame(year = 2002:2013, cor = tail(cor_factors, 1)$cor)
)

save(cor_factors, file = 'data/cor_factors.rdata', compress = 'xz')