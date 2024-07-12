library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(lubridate)
library(readr)
library(rvest)

#==============================================================================#
# Scrap url of presentation with attached material                          ####
#==============================================================================#

html_elem_pres_attached <-
  read_html(paste0("https://userconf2024.sched.com/overview/area/Yes")) |>
  html_elements(".event") |>
  html_elements("a")

# title <- html_text(html_elem_pres_attached)
link_to_page <-
  paste0(
    "https://userconf2024.sched.com/",
    html_attr(html_elem_pres_attached, "href")
  )

dat_presentation <-
  tibble(
    # title = title[,1],
    url = link_to_page
  )

#==============================================================================#
# Add attached material link/title/filename and tidy data                   ####
#==============================================================================#

single_page <-
  map(
    dat_presentation$url,
    read_html,
    .progress = TRUE
  )

dat_presentation_with_material <-
  dat_presentation |>
  mutate(
    title =
      map_chr(
        single_page,
        \(x) html_element(x, ".list-single__event") |>
          html_text() |>
          str_squish() |>
          str_remove("\\s\\[.+\\]"),
        .progress = "Collecting attachments url..."
      ),
    date =
      map_chr(
        single_page,
        \(x) html_element(x, ".list-single__date") |>
          html_text() |>
          str_squish() |>
          str_remove(" -.+$"),
        .progress = "Collecting attachments url..."
      ),
    attachment_url =
      map(
        single_page,
        \(x) html_elements(x, ".file-uploaded") |>
          html_attr("href"),
        .progress = "Collecting attachments url..."
      )
  ) |>
  unnest(attachment_url) |>
  mutate(
    date =
      as_datetime(
        paste0(
          "2024-07-",
          case_when(
            str_starts(date, "Mon") ~ "08",
            str_starts(date, "Tue") ~ "09",
            str_starts(date, "Wed") ~ "10",
            str_starts(date, "Thu") ~ "11",
          ),
          " - ", str_extract(date, "\\d{2}:\\d{2}"), ":00"
        ),
        tz = "CET"
      ),
    file_name = URLdecode(str_extract(attachment_url, "[^/]+$"))
  ) |>
  arrange(date, title) |>
  select(!url) |>
  mutate(file_name = paste0(row_number(), "_", file_name))

write_csv2(dat_presentation_with_material, "user_2024_files_url.csv")

#==============================================================================#
# Download the attached material                                            ####
#==============================================================================#

walk2(
  dat_presentation_with_material$attachment_url,
  dat_presentation_with_material$file_name,
  \(x, y) download.file(x, here::here("attached_files", y), mode = "wb")
)
