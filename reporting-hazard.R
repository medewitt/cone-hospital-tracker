library(data.table)
library(dplyr)
library(purrr)
library(ggplot2)

target_files <- fs::dir_ls("data-raw")

dat_raw <- rbindlist(lapply(target_files, fread), idcol = "report_date")


dat_raw[,report_date:=as.Date(substr(basename(report_date),1,10))]


reporting_hazard <- dat_raw %>%
	filter(date >= min(report_date))  %>%
	group_by(date) %>%
	mutate(perc = cases/max(cases)) %>%
	arrange(date) %>%
	filter(report_date < Sys.Date()-3) %>%
	mutate(report_n = as.numeric(report_date) - as.numeric(date)+1) %>%
	mutate(prob = perc-dplyr::lag(perc,1,0))



reporting_hazard %>%
	filter(date >= min(report_date))  %>%
	ggplot(aes(date, cases, group = report_date,
						 alpha = prob))+
	geom_line()


reporting_hazard %>%
	filter(report_date < Sys.Date()-3) %>%
	filter(date >= min(report_date))  %>%
	ungroup() %>%
	select(report_n,prob) %>%
	group_by(report_n) %>%
	summarise(prob = round(mean(prob),2)) %>%
	ungroup()->reporting_prob


reporting_prob %>%
	ggplot(aes(report_n,prob))+
	geom_line()
