# put treemap() into a wrapper
# taken from: https://www.data-to-viz.com/caveat/pie.html

tree = function(dt, index, vsize) {
  treemap(
    dt,
    # data
    index = index,
    vSize = vsize,
    type = "index",
    # Main
    title = "",
    palette = "Dark2",
    # Borders:
    border.col = c("black"),
    border.lwds = 1,
    # Labels
    fontsize.labels = 0.5,
    fontcolor.labels = "white",
    fontface.labels = 1,
    bg.labels = c("transparent"),
    align.labels = c("left", "top"),
    overlap.labels = 0.5,
    inflate.labels = TRUE # If true, labels are bigger when rectangle is bigger.
  )
}
