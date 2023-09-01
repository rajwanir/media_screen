library(tidyverse)
# activity = read_csv("data/experiments/mo_amy/activity.csv")
# selected60 = activity %>% group_by(plate) %>% filter(od < mean(od)*0.6)
# tail7 = activity %>% group_by(plate) %>% summarize(tail7 = paste(tail(sort(od,decreasing = T)),collapse = ","))
# selected60 = left_join(selected60,tail7)
# write_csv(selected60,"data/experiments/mo_amy/selected60.csv")


activity = read_csv("activity_correct.csv")
activity = activity %>% mutate(sample_type = case_when(well %in% c("A11","A12") ~ "Vancomycin control", 
                                                       str_detect(well,"11|12") ~ "E. faecalis only",
                                                       TRUE ~ "E. faecalis + A. kerathiniphila spent media"))

mean_negative = activity %>% filter(str_detect(well,"11|12")) %>% filter(!well %in% c("A11","A12")) %>% group_by(plate) %>% summarize(mean_negative = mean(od))

activity = left_join(activity,mean_negative,by="plate") %>% mutate(percent_growth = od/mean_negative * 100)

p_activity = ggplot(activity,aes(percent_growth,fill=sample_type)) + 
  geom_histogram(color="black") +
  facet_wrap(~plate,nrow=1) +
  labs(y="# of wells" , x= "Percent growth (%)") +
  ggprism::theme_prism(base_fontface = "plain") +
  scale_fill_manual(values=c("Vancomycin control" = "red",
                             "E. faecalis only" = "navy",
                             "E. faecalis + A. kerathiniphila spent media" = "grey")) +
  theme(legend.position = "right") + 
  scale_x_continuous(breaks = seq(0,200,50))


ggsave("activity_screen.svg",p_activity,width=18,height=2)


activity_validation = read_csv("activity_validation.csv")
activity_validation$condition = factor(activity_validation$condition,levels = c("E. faecalis only",
                                                "E. faecalis  + H2O",
                                                "E. faecalis + P3B1 media only",
                                                "E. faecalis + random spent media",
                                                "E. faecalis + P3B1 spent media",
                                                "E. faecalis + vancomycin (3uM)"))
p_validation = ggplot(activity_validation,aes(x=condition,y=od)) +
  geom_boxplot() +
  geom_point(position="jitter") +
  ggprism::theme_prism(base_fontface = "plain")  + 
  scale_y_continuous(breaks = seq(0,1.5,0.25))+
  labs(y="OD 600nm",x="Condition") +
  coord_flip()

  
ggsave("P3B1_validation.svg",p_validation,width=7,height=2)