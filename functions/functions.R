## functions written during the species sensitivity project:

#### 1 geometric mean --------
gm_mean <- function(x) exp(mean(log(x)))

#### 2 ksource --------
# https://stackoverflow.com/questions/10966109/how-to-source-r-markdown-file-like-sourcemyfile-r
# doesn't load eval=FALSE
ksource = function(x, ...) {
  library(knitr)
  source(purl(x, output = tempfile()), ...)
}
