# URL: http://www.ssa.gov/oact/babynames/names.zip
url1 = "http://www.ssa.gov/oact/babynames/names.zip"
tf <- tempfile(fileext = ".zip")


if (!file.exists('rawdata/names')){
  downloader::download(url1, tf)
  dir.create('rawdata/names')
  unzip(tf, exdir = 'rawdata/names')
}

files = list.files('rawdata/names', pattern = '.txt', full.names = T)

bnames = plyr::ldply(files, function(f){
  dat = read.csv(f, header = F, 
    colClasses = c('character', 'character', 'integer'),
    col.names = c('name', 'sex', 'n'),
  )
  dat$year = as.numeric(gsub("^(.*yob)(\\d{4})\\.txt$", "\\2", f))
  dat[,c('year', 'sex', 'name', 'n')]
})

save(bnames, file = 'data/bnames.rdata', compress = 'xz')

url2 <- "http://www.ssa.gov/oact/babynames/state/namesbystate.zip"

if (!file.exists('rawdata/namesbystate')){
  tf <- tempfile(fileext = ".zip")
  downloader::download(url2, tf)
  dir.create('rawdata/namesbystate')
  unzip(tf, exdir = 'rawdata/namesbystate')
}

files2 = list.files('rawdata/namesbystate', pattern = '.TXT', full.names = T)

bnames_by_state = plyr::ldply(files2, function(f){
  dat = read.csv(f, header = F, 
    colClasses = c('character', 'character', 'integer', "character", "integer"),
    col.names = c('state', 'sex', 'year', 'name', 'n'),
  )
  dat[,c('year', 'sex', 'name', 'state', 'n')]
}, .progress = 'text')

save(bnames_by_state, file = 'data/bnames_by_state.rdata', compress = 'xz')

