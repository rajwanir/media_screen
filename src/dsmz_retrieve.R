


recipe = lapply(dsmz$id, function(i){
  jsonlite::fromJSON(content(GET(
    url = sprintf("https://mediadive.dsmz.de/rest/medium/%s", i)
  ), "text"))$data$solutions$recipe[[1]]
})

recipe = read_csv("data/DSMZ_recipe.csv")
comp_filter = c("Distilled water","Tap water","Sea water","Agar")
media_id_skips = c(514,260,547,310)

recipe = filter(recipe,!compound %in% comp_filter & !media_id%in%media_id_skips)
recipe$complex_compound = replace_na(recipe$complex_compound,2)
recipe = recipe %>% group_by(media_id) %>% mutate(all_compounds= paste(sort(compound_id),collapse = ",")) %>%
   ungroup() %>% arrange(medium) %>% 
  distinct(all_compounds,compound,.keep_all=T) 
recipe = mutate(recipe,compound = case_when(complex_compound==2 ~ "Trace solution", TRUE ~ compound))
recipe$compound = factor(recipe$compound,levels = unique(recipe$compound[order(recipe$complex_compound)]), ordered=T)


  
  recipe_matrix = mutate(select(recipe,medium,compound,amount),amount=replace_na(amount,0))
  recipe_matrix = pivot_wider(recipe_matrix,
                              names_from = "compound",values_from = "amount",id_cols = "medium",values_fill=0)
  recipe_matrix = recipe_matrix %>% column_to_rownames("medium")

  media_cluster = pheatmap::pheatmap(recipe_matrix,scale="row",
                   breaks=seq(0.1,10,by=0.5),
                   cluster_cols = F,
                   border_color ="black",
                   color=colorRampPalette(c("white","navy"))(20))
  recipe$medium= factor(recipe$medium, levels = media_cluster$tree_row$labels[media_cluster$tree_row$order],
         ordered=T)

  
p_recipe = ggplot(recipe,
         aes(x=fct_infreq(compound),y=str_to_sentence(recipe$medium))) + 
    geom_tile(aes(fill=amount),color="black") +
    geom_text(aes(label=floor(amount)),size=3) +
    viridis::scale_fill_viridis(limits=c(0,10)) +
    theme_classic()+
    facet_grid(~complex_compound,scales = "free_x",space="free",
               labeller=labeller(complex_compound=c("0"="Simple","1"="Complex","2"="Solution"))) +
    labs(x="Ingredients\n(sorted by freq.)",y="Media\n(sorted by similarity)") +
    theme(axis.text.x = element_text(angle=90),
          panel.grid.major = element_line(color="black"),
          strip.text = element_text(angle=90),
          axis.text=element_text(color="black"))   


comp_labels = read_csv("ingredient_list.csv")
recipe = left_join(recipe,comp_labels)
recipe$newlabel = factor(recipe$newlabel,levels = unique(recipe$newlabel[order(recipe$complex_compound)]), ordered=T)

p_compound_freq =   ggplot(filter(recipe,complex_compound!=2 & compound!="ISP 7 Medium"),
         aes(x=fct_infreq(newlabel))) + geom_bar(fill="antiquewhite",color="black") + 
    scale_y_continuous(breaks=1:25) +
    geom_hline(yintercept = 2,color="brown",size=2) +
    facet_wrap(~complex_compound,scales="free",
               labeller=labeller(complex_compound=c("0"="Simple","1"="Complex","2"="solution"))) +
    labs(x="Ingredient",y="# of media") +
    ggtitle("Frequently used ingredients in Streptomyces media") +
    coord_flip() +
    theme_bw() +
    theme(panel.grid.major = element_line(color="black"),
          axis.text=element_text(color="black"),
          plot.title = element_text(hjust=0.5)) 

ggsave("figures/compound_freq.svg",p_compound_freq,width=12,height=4.5)

# cowplot::plot_grid(p_recipe,p_compound_freq,ncol=1,rel_heights = c(1,0.65),
#                    labels = c("A","B"))
  

recipe %>% group_by(media_id) %>%
  filter(complex_compound ==1&compound!="Agar") %>%
  summarize(n_complex = sum(complex_compound),comp = paste(compound,collapse = ", "))

