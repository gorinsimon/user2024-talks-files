
devtools::install_github("bartonicek/plotscape/packages/plotscaper")

library(plotscaper)
imdb <- read.csv("imdb1000.csv")
dplyr::glimpse(imdb)

set_scene(imdb, list(point_queries = c("title", "director"))) |>
  add_scatterplot(c("runtime", "votes")) |>
  add_barplot(c("director")) |>
  add_fluctplot(c("genre1", "genre2")) |>
  add_barplot(c("rating"))

set_scene(imdb, list(point_queries = c("title", "director"))) |>
  add_scatterplot(c("runtime", "votes")) |>
  add_barplot(c("year", "votes"),
              list(reducer = reducer(
                name = "max",
                initialfn = "() => 0",
                reducefn = "(a, b) => Math.max(a, b)"
              )))

