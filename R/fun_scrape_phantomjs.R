# function to scrape web sites that load their content via JS functions
# http://www.rladiesnyc.org/post/scraping-javascript-websites-in-r/
# PhantomJS needs to be installed!

# Java script -------------------------------------------------------------
writeLines(
  text =
    "var url ='http://www.example.com';
    var page = new WebPage()
    var fs = require('fs');


    page.open(url, function (status) {
      just_wait();
    });

    function just_wait() {
      setTimeout(function() {
        fs.write('1.html', page.content, 'w');
        phantom.exit();
      }, 2500);
    }",
  con = file.path(tempdir(), 'scrape.js')
)

# R -----------------------------------------------------------------------
js_scrape = function(url = 'http://www.example.com',
                     js_path = file.path(tempdir(), 'scrape.js'),
                     phantompath = '/usr/local/bin/phantomjs',
                     file = file.path(tempdir(), 'file.html')) {
  
  lines = readLines(js_path)
  lines[1] = paste0("var url = '", url ,"';")
  lines[12] = paste0("        fs.write('", file, "', page.content, 'w');")
  writeLines(lines, js_path)
  
  command = paste(phantompath, js_path, '/tmp/test.html', sep = " ")
  system(command)
  
  message('Saving to: ', file)
}








