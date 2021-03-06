library(tidyverse)
library(rio)
library(janitor)
library(ggplot2)
library(here)
library(maps)
library(dplyr)
library(gghighlight)
library(plotly)

initial <- import(here("data", "food_carbon_footprint_data.xlsx")) %>% 
  clean_names() %>%
    as_tibble()

#change ranking variable to numeric
#filter out the top ten highest CO2/person/year
subset <- initial %>% 
  mutate(ranking = as.numeric(ranking)) %>% 
  filter(ranking < 7 |country == "average"| country =="Canada"|country =="Japan"
         |country == "Germany"|country =="Mexico"|country =="South Korea"|country =="China")

#Im not too clear on the filtering out top 10 distinction, is this by ranking or highest value of one of the columns? 

#line plot work: CO2/person/year produced by country

initial_longer <- subset %>%
  select("ranking", "country","total_animal_products", "total_nonanimal_products", 
         "animal_nonanimal_difference") %>% 
  pivot_longer(cols = 3:5,
               names_to = "product",
               values_to = "CO2_person_year")

nadiff <- subset %>%
  arrange(desc(animal_nonanimal_difference)) %>% 
  select("ranking", "country", "animal_nonanimal_difference") %>% 
  pivot_longer(cols = 3,
               names_to = "product",
               values_to = "CO2_person_year")

animal <- subset %>%
  pivot_longer(cols = 3:9,
               names_to = "product",
               values_to = "CO2_person_year")

non_animal <- subset %>%
  pivot_longer(cols = 11:14,
               names_to = "product",
               values_to = "CO2_person_year")

#Nice use of pivot_longers! 

  #plot1: animal products
#draft

a1 <- animal %>% 
  ggplot(aes(product, CO2_person_year, group=country)) +
  geom_line(aes(color = country))
a1

#final
a2 <- animal %>% 
  ggplot(aes(product, CO2_person_year, group=country)) +
  geom_line(aes(color = country), size = 1) +
  gghighlight(country == "average" |country == "USA" | country =="Canada"| country =="Japan") +
  scale_color_viridis_d() +
  scale_x_discrete(expand = c(0, 0)) +
  labs(title = "CO2/person/year for animal products",
       subtitle = "",
       x = "animal product",
       y = "Co2/person/year (in Kg)") +
  theme_minimal()
a2 

#Nice plot! The (global?) average value is a nice base line but it could be mistaken for the average values that are plotted?
#But the color distinction makes the countries of interest very salient! 

ggplotly(a2, tooltip = c("country","product","CO2_person_year"))

  #plot2: non-animal products
#draft
na1 <- non_animal %>% 
  ggplot(aes(product, CO2_person_year, group=country)) +
  geom_line(aes(color = country))
na1

#final
na2 <- non_animal %>% 
  ggplot(aes(product, CO2_person_year, group=country)) +
  geom_line(aes(color = country), size = 1) +
  gghighlight(country == "average" |country == "USA" | country =="Canada"| country =="Japan") +
  scale_color_viridis_d() +
  scale_x_discrete(expand = c(0, 0)) +
  labs(title = "CO2/person/year for non-animal products",
       subtitle = "",
       x = "non-animal product",
       y = "Co2/person/year (in Kg)") +
  theme_minimal()
na2

ggplotly(na2, tooltip = c("country","product","CO2_person_year"))

#The color distinction is nice as always, tho is there a reason for the organiation of the x variables? 
#Ordering x variables from the average high to low values may be an alternative visualisation and show which 
#countries produce more CO2/Persno/year/Product? compared to the average, I'm not sure if I'm makeing sense so please ignore if not.  

#plot3: difference between animal and non-animal products
#draft
d1 <- nadiff %>% 
  ggplot(aes(CO2_person_year, country)) +
  geom_col(aes(fill = country))
d1
#final

d2 <- nadiff %>% 
  ggplot(aes(CO2_person_year, reorder(country, CO2_person_year))) +
  geom_col(aes(fill = country)) +
  geom_col(data = filter(nadiff, country == "average" |country == "USA"),
           fill = "#C55644") + 
  scale_fill_viridis_d() +
  labs(title = "Animal v. Non-Animal Products difference",
       subtitle = "",
       x = "Co2/person/year (Kg)",
       y = "") +
  theme_minimal() +
  theme(legend.position = "none")
d2
ggplotly(d2, tooltip = c("CO2_person_year"))

#Great color scheme, especially the top 3 dcountries being a shade darker draws attention

#not currently using
#geographic plot work
#bring in map
country_data <- map_data("world") %>% 
  rename(country=region)

#left join initial and country_data by country
data_map<-full_join(initial, country_data)

#maybe use a map type other than albers; mercator?
#need outlines for all countries; full join? 
#now countries without data are filled grey

#plot of difference by country on map
ggplot(data_map, aes(long, lat))+
  geom_polygon(aes(group=group, color = "red", fill=animal_nonanimal_difference))
               +coord_map("albers", at0 = 45.5, lat1 = 29.5)

ggplot(initial, aes(total_animal_products,country)) +
  geom_point(aes(color=ranking))
  
ggplot(initial, aes(total_animal_products,ranking)) +
  geom_point() +
  labs(title = "kg CO2 per person")