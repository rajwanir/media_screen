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
all_wells = paste0(expand.grid(LETTERS[1:8],1:12)$Var1,
                   expand.grid(LETTERS[1:8],1:12)$Var2)
dsmz_components = read_csv("data/dsmz_ingredients_frequent.csv") # will use compound names from here
dsmz_components$ot2_label = janitor::make_clean_names(tolower(dsmz_components$compound))
dsmz_components = select(dsmz_components,ot2_label,component=compound_id)
dsmz_components = mutate(dsmz_components,component=as.character(component))
plates= expand.grid(paste0("P",1:no_of_plates),
                    all_wells
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
