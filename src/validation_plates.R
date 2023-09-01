# for validataion
plates = read_csv("data/experiments/mo_amy/media_template_nacl.csv")
plates = plates %>% mutate(media_id=paste(plate,well,sep="-"))
all_media_ids = unique(plates$media_id)
all_wells = paste0(expand.grid(LETTERS[1:8],1:12)$Var1,
                   expand.grid(LETTERS[1:8],1:12)$Var2)

# seed 10,20,100
positive_media_id=c("P5-H3","P5-H4","P5-H5","P5-H6","P5-H7","P4-H1","P3-C8","P3-A9","P3-B1",
                    "P2-A3","P2-A1","P2-B1")

pos_val_plate = plates %>% filter(media_id %in% positive_media_id)
pos_val_plate = bind_rows(mutate(pos_val_plate,rep=1),mutate(pos_val_plate,rep=2),mutate(pos_val_plate,rep=3)) %>% arrange(media_id)
pos_val_plate=mutate(pos_val_plate,media_id_rep=paste(media_id,rep,sep="-"))
pos_val_plate = left_join(pos_val_plate,
                          tibble(media_id_rep=pos_val_plate$media_id_rep,
                                 new_well=all_wells[1:length(pos_val_plate$media_id_rep)],
                                 new_plate="P1")
)  

skip_ot2_label = "beef_extract"
skip_media_id  = unique(plates$media_id[plates$ot2_label==skip_ot2_label])
control_media_id = sapply(c(10, 20, 40), function(s) {
  set.seed(s)
  all_media_ids[sample(x = c(1:length(all_media_ids))[-which(all_media_ids %in% positive_media_id|
                                                               all_media_ids %in% skip_media_id) ],
                       size = length(positive_media_id))]
}) %>% as.vector()


control_val_plate = plates %>% filter(media_id %in% control_media_id) %>% arrange(media_id)
control_val_plate = left_join(control_val_plate,
                              tibble(media_id=control_media_id,
                                     new_well=all_wells[-which(all_wells %in% pos_val_plate$new_well)][1:length(control_media_id)],
                                     new_plate="P1")
)  

validation_plate = bind_rows(pos_val_plate,control_val_plate)

write_csv(validation_plate,"data/ot2_protocols/validation_template_96well.csv")