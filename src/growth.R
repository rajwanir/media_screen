library(tidyverse)

growth = read_csv("data/experiments/GA13-001/growth/template.csv")
media = read_csv("data/ot2_protocols/ot2_media_template.csv")
growth = mutate(growth,plate=paste0("P",plate))
no_growth_counts = left_join(media,growth) %>% group_by(ot2_label) %>% 
  summarize(n_inhibition = sum(growth<4),
            n_total = n()) %>% mutate(perecent_inhibition = n_inhibition/n_total)

# component wise growth inhibition  
p_growth = ggplot(no_growth_counts) + geom_bar(aes(x=fct_reorder(ot2_label,-perecent_inhibition),y=perecent_inhibition),stat="identity",fill="cornsilk1",color="black") +
    ggprism::theme_prism(base_fontface = "plain") +
    labs(x="Component",y="conditions \n with growth inhibition (%)") +
    ggtitle("Growth inhibition") +
    scale_y_continuous(labels = scales::label_percent()) +
    coord_flip()



# main contributor to growth inhibition
main_contributor = tibble(total_inhibited_wells = left_join(media,growth) %>% filter(growth<4) %>% distinct(plate,well) %>% nrow(),
       wells_containing_inhibit_comp = left_join(media,growth) %>% filter(growth<4) %>% group_by(plate,well) %>% filter(any(ot2_label=="malt_extract")) %>% 
         ungroup() %>% distinct(plate,well) %>%  nrow())
svg("data/experiments/GA13-001/growth/growth_inhibit_pie.svg")
pie(c(main_contributor$total_inhibited_wells-main_contributor$wells_containing_inhibit_comp,main_contributor$wells_containing_inhibit_comp),
    labels=c("without malt extract","with malt extract"),
    main="Wells that show growth inhibition")
dev.off()
#growth rescue
inhibitory_component="malt_extract"
left_join(media,growth) %>% group_by(plate,well) %>% filter(any(ot2_label==inhibitory_component)) %>% ungroup() %>%  count(ot2_label)

combined_growth_inhibition = left_join(media,growth) %>% group_by(plate,well) %>% filter(any(ot2_label==inhibitory_component) ) %>% # media that contains inhibit component
  ungroup() %>% filter(ot2_label!=inhibitory_component) %>%  group_by(ot2_label) %>%  # grouping by ot2_label
  summarize(total_with_inhibitory_component = n(),
            n_rescuing_growth = sum(growth<4),
            percent_rescue = n_rescuing_growth/total_with_inhibitory_component) %>% arrange(-percent_rescue)


p_c_inhibtion = ggplot(combined_growth_inhibition) + geom_bar(aes(x=fct_reorder(ot2_label,-percent_rescue),y=percent_rescue),stat="identity",fill="cornsilk1",color="black") +
  ggprism::theme_prism(base_fontface = "plain") +
  labs(x="Component",y="combination resulting in\n growth inhibition(%)") +
  ggtitle("ME + x --> growth inhibition") +
  scale_y_continuous(labels = scales::label_percent()) +
  coord_flip()

ggsave("data/experiments/GA13-001/growth/growth_inhibit.svg",
cowplot::plot_grid(p_growth,p_c_inhibtion),width=10)



# color 
left_join(media,color) %>% ggplot() +
  geom_bar(aes(x=ot2_label,fill=color),position="fill",color="black") +
  scale_fill_manual(values=c("green"="darkgreen","purple"="purple","brown"="antiquewhite")) +
  scale_y_continuous(labels = scales::percent) +
  labs(x="Ingredient",y="All media") +
  ggprism::theme_prism(base_fontface = "plain") + 
  ggtitle("Ingredients associated with color production") +
  theme(legend.position = "top", title = element_text(hjust=0.5)) +
  coord_flip() 


pie(table(color$color),
    col=c("antiquewhite","darkgreen","purple"),
    labels = paste0(round(100*table(color$color)/sum(table(color$color)), 1),"%"),
    main="Colored GA7-009 cultures across 1025 media",
    font.main=1)
