## code to prepare `baby_names` dataset goes here
# https://data.ontario.ca/dataset/ontario-top-baby-names-male
boy_names <- readr::read_csv("data-raw/ontario_top_baby_names_male_1917-2019_en_fr.csv",skip = 1) %>%
  dplyr::rename(year = 1, name = 2, freq = 3) %>%
  dplyr::mutate(gender = "male")

#https://data.ontario.ca/dataset/ontario-top-baby-names-female/
girl_names <- readr::read_csv("data-raw/ontario_top_baby_names_female_1917-2019_en_fr.csv",skip = 1) %>%
  dplyr::rename(year = 1, name = 2, freq = 3) %>%
  dplyr::mutate(gender = "female")

baby_names <- dplyr::bind_rows(boy_names, girl_names) %>%
  dplyr::filter(nchar(name) > 1 & year >= 1917)  %>%
  dplyr::ungroup() %>%
  dplyr::mutate(select_label = sprintf("%s (%s)", name, gender))

top_yearly_names <- baby_names %>%
  dplyr::arrange(year, dplyr::desc(freq)) %>%
  dplyr::group_by(year, gender) %>%
  dplyr::slice_head(n=1)

baby_names_forselect <- baby_names %>%
#  dplyr::mutate(select_label = sprintf("%s (%s)", name, gender)) %>%
  dplyr::select(-gender) %>%
  dplyr::select(name, select_label) %>%
  dplyr::distinct() %>%
  dplyr::arrange(name)


baby_names_forselect <- baby_names_forselect$select_label


usethis::use_data(baby_names_forselect, overwrite = TRUE)
usethis::use_data(baby_names, overwrite = TRUE)
usethis::use_data(top_yearly_names, overwrite = TRUE)
