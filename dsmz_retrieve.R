


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

  
  ggplot(recipe,
         aes(x=fct_infreq(compound),y=medium)) + 
    geom_tile(aes(fill=amount),color="black") +
    geom_text(aes(label=floor(amount))) +
    viridis::scale_fill_viridis(limits=c(0,10),alpha=0.5) +
    theme_classic()+
    facet_grid(~complex_compound,scales = "free_x",space="free",
               labeller=labeller(complex_compound=c("0"="Simple","1"="Complex","2"="solution"))) +
    labs(x="Ingredients\n(sorted by freq.)",y="Media\n(sorted by similarity)") +
    theme(axis.text.x = element_text(angle=90),
          panel.grid.major = element_line(color="black"),
          axis.text=element_text(color="black"))   

  ggplot(filter(recipe,complex_compound!=2),
         aes(x=fct_infreq(compound))) + geom_bar(fill="antiquewhite",color="black") + 
    scale_y_continuous(breaks=1:25) +
    geom_hline(yintercept = 2,color="brown",size=2) +
    facet_wrap(~complex_compound,scales="free",
               labeller=labeller(complex_compound=c("0"="Simple","1"="Complex","2"="solution"))) +
    labs(x="Ingredient",y="# of media") +
    ggtitle("Frequency of ingredients across media") +
    coord_flip() +
    theme_bw() +
    theme(panel.grid.major = element_line(color="black"),
          axis.text=element_text(color="black"),
          plot.title = element_text(hjust=0.5))   
  

recipe %>% group_by(media_id) %>%
  filter(complex_compound ==1&compound!="Agar") %>%
  summarize(n_complex = sum(complex_compound),comp = paste(compound,collapse = ", "))

# theoretical combinations
thr_mix = tibble(setsize=7,mix=1:3 ,combinations=choose(setsize,mix), cumulative=cumsum(combinations))
ggplot(thr_mix,
         aes(x=setsize,y=cumulative)) + geom_line() + geom_point() +ggrepel::geom_label_repel(aes(label=cumulative))


# real combinations
set1 = sapply(1:3,function(i) combn(1:6,i,simplify = T),simplify = T)
set1[[1]] = rbind(set1[[1]],matrix(rep(0,ncol(set1[[1]])*2),ncol=ncol(set1[[1]]))) # making a 3 row matrix
set1[[2]] = rbind(set1[[2]],matrix(rep(0,ncol(set1[[2]])),ncol = ncol(set1[[2]]))) # making a 3 row matrix
set1 = cbind(set1[[1]],set1[[2]],set1[[3]])

set2 = sapply(1:3,function(i) combn(7:11,i,simplify = T),simplify = T)
set2[[1]] = rbind(set2[[1]],matrix(rep(0,ncol(set2[[1]])*2),ncol=ncol(set2[[1]]))) # making a 3 row matrix
set2[[2]] = rbind(set2[[2]],matrix(rep(0,ncol(set2[[2]])),ncol = ncol(set2[[2]]))) # making a 3 row matrix
set2 = cbind(set2[[1]],set2[[2]],set2[[3]])

set3 = expand.grid(1:ncol(set1),1:ncol(set2))
set3 = rbind(set1[,set3[,1]],set2[,set3[,2]])
set3 = sapply(1:ncol(set3), function(i) paste(set3[,i],collapse = "-"))


set3=matrix(set3,ncol=12,byrow = T)
set3=lapply(seq(1,nrow(set3),by=8),function(i) 
  if(i+7<nrow(set3))
    return(set3[i:(i+7),])
  else return(set3[i:nrow(set3),])   )


p_set3 = lapply(1:length(set3),function(i)
ggplot(reshape2::melt(set3[[i]]),aes(y=Var1,x=Var2,label=value)) +
  geom_tile(fill="white",color="black")+  geom_text(size=1.7) +
  scale_y_continuous(breaks=1:8,labels = LETTERS[1:8],expand=c(0,0)) + 
  scale_x_continuous(breaks=1:12,expand=c(0,0)) + theme_classic() + labs(x=NULL,y=NULL) +
  ggtitle(sprintf("Plate %d",i)) +
  theme(plot.title = element_text(hjust=0.5))
)

ggsave("plates.pdf", gridExtra::marrangeGrob(grobs = p_set3, nrow=2, ncol=1),
       device = "pdf")


#writing template for opentrons from set3(vector)
no_of_plates=11
transfervol=2
dsmz_components = read_csv("data/dsmz_ingredients_frequent.csv") # will use compound names from here
dsmz_components$ot2_label = janitor::make_clean_names(tolower(dsmz_components$compound))
dsmz_components = select(dsmz_components,ot2_label,component=compound_id)
dsmz_components = mutate(dsmz_components,component=as.character(component))
plates= expand.grid(paste0("P",1:no_of_plates),
paste0(expand.grid(LETTERS[1:8],1:12)$Var1,
       expand.grid(LETTERS[1:8],1:12)$Var2)
)

plates = mutate(plates,plate_well=paste(Var1,Var2,sep="@"))
#paste(plates$Var1,plates$Var2,sep="@")
plates = plates %>% arrange(Var1) # to arrange well wise, currently omits 2 wells per plate
plates = tibble(components = set3,position = paste(plates$Var1,plates$Var2,sep="@")[1:length(set3)])
plates = separate(plates,components,sep="-",into=paste0("component",1:6)) %>% 
pivot_longer(starts_with("component"),names_to="component_no",values_to="component")
plates = separate(plates,col="position", sep="@",into=c("plate","well"))
plates = left_join(plates,dsmz_components)
plates = mutate(
  plates,
  vol = case_when(
    ot2_label == "glycerol" ~ transfervol * 2,
    ot2_label == "yeast_extract" ~ transfervol * 2,
    ot2_label == "malt_extract" ~ transfervol * 2,
    ot2_label == "water" ~ 190,
    TRUE ~ transfervol
  )
)
plates = plates %>% arrange(plate,component)
plates = filter(plates,component!=0)

write_csv(plates,"C:/Users/rajwanir2/Documents/Python Scripts/ot2_media_template.csv")