

brown = read_csv("data/experiments/GA13-001/color/browncolor_detailed_height_filtered.csv")
brown = janitor::clean_names(brown)
brown = brown %>% pivot_longer(starts_with("p"),names_to="sample",values_to="peak_height")
brown = mutate(brown,condition=str_remove(str_extract(sample,".*_r"),"_r"), replicate = str_extract(sample,"rep\\d+"))
brown = brown %>% filter(condition!="p4c11_10xk2hpo4")
brown %>% 
  group_by(mass_avg,rt_avg) %>%
  summarize(x10 = mean(peak_height[condition=="p4c11_10xn_z_amine"]),
            x1 = mean(peak_height[condition=="p4c11"])) %>% 
  replace_na(list(x10= 0,x1=0)) %>% 
  mutate(fc=x10/x1) %>% filter(fc>4)



# green violet  GA7-009
data = read_csv("area.csv") %>% janitor::clean_names()
data = data %>% filter(if_any(starts_with("blank"), ~ .!=0)) # blank filter

data = data %>% select(-c(compound_name,formula,cas_id)) %>% pivot_longer(!c(mass,rt),names_to="well",values_to="peak_area")

data = data %>% mutate(media = case_when(str_detect(well,"2")~"purple",
                                         str_detect(well,"3")~"green",
                                         str_detect(well,"4")~"random")
)
data = data %>% replace_na(list(peak_area=0))
summary = data %>% group_by(mass,rt) %>% 
  summarize(m_purple=mean(peak_area[media=="purple"]),
            m_green=mean(peak_area[media=="green"]),
            m_random=mean(peak_area[media=="random"]),
            log2fc_g = log2(m_green/m_random),
            log2fc_p = log2(m_purple/m_random),
            p_green=t.test(peak_area[media=="green"],peak_area[media=="random"])$p.value,
            p_purple=t.test(peak_area[media=="green"],peak_area[media=="random"])$p.value)



# retrieving kegg compounds
kegg = read_delim("data/experiments/GA7-009/heme_keggcompounds.txt",delim = "               ",col_names = c("kegg_id","kegg_name"))
kegg$pubchem = sapply(kegg$kegg_id,function(id){
  record = httr::GET(sprintf("https://rest.kegg.jp/get/%s/",id))
  #mass=as.numeric(str_remove(str_extract(content(record),pattern = "EXACT_MASS  \\d+.\\d+"),"EXACT_MASS  "))
  pubchem=as.numeric(str_remove(str_extract(content(record),pattern = "PubChem: \\d+"),"PubChem: "))
  return(pubchem)})

# volcano plot
data = read_csv("validation_plate/comparision.csv")
data = mutate(data, change = case_when(log2fc_g>1 & p_green<0.05 ~ "more abundant",
                                       log2fc_g < -1 & p_green<0.05 ~ "less abundant",
                                       TRUE ~ "insignificant") )

target = bind_rows(data %>% filter(between(mass,654.26,654.27)),data %>% filter(between(mass,600.34,600.37)))


p_volcano  = ggplot(data,aes(log2fc_g,-log10(p_green))) + 
  geom_point(aes(color=change)) +
  geom_point(data=target,aes(log2fc_g,-log10(p_green)), color = "red",inherit.aes = F) +
  ggrepel::geom_text_repel(data=target,aes(log2fc_g,-log10(p_green),label=mass), 
                           inherit.aes = F,xlim=c(7,11)) +
  scale_color_manual(values=c("more abundant" = "darkgreen",
                              "less abundant" = "blue",
                              "insignificant" = "grey")) +
  labs(x="log2(fold change)",y="-log10(p-value)")+
  ggprism::theme_prism(base_fontface = "plain") +
  theme(legend.position = "top")

ggsave(p_volcano,filename = "volcano.svg",height=4,width=6)
## box plot
df_area = read_csv("refcompouds_area.csv")
#df_area$medium = factor(df_area$medium,levels = c("P1A7","random","10xbeefext","10xgluc","10xmgs04",ordered=T))
df_area$medium = factor(df_area$medium,levels = c("P10A4","P5A4","random",ordered=T))

p_plot = ggplot(df_area,aes(x=medium,y=DeferoxamineE)) +
  geom_boxplot() +
  geom_point(position = "jitter",size=3) +
  scale_y_continuous(trans = scales::log10_trans()) +
  ggprism::theme_prism(base_fontface = "plain",base_family = "calibri") + 
  labs(y="DeferoxamineE \n(m/z 601.355)",
       x="Medium")

ggsave(p_plot,filename = "DeferoxamineE_area.svg",height=2.5,width=6)


#mgso4 dose response
dose = read_csv("mgso4_area.csv")
dose$concentration  = factor(as.character(dose$concentration_mM),levels=unique(str_sort(as.character(dose$concentration_mM),numeric = T)))
p_plot = ggplot(dose,aes(x=concentration,y=coporphyrin)) +
  geom_point(position = "jitter") +
  geom_boxplot() +
  scale_y_continuous(trans = scales::log10_trans()) +
  ggprism::theme_prism(base_fontface = "plain",base_family = "calibri") + 
  labs(y="DeferoxamineE \n(m/z 601.355)",
       x="MgSO4.7H20 concentration (mM)")

df_area = read_csv("area_defroxamine_metalions.csv")
df_area$medium = factor(df_area$medium,levels = c("P10A4","P5A4","ISP1",ordered=T))
df_area$additive = factor(df_area$additive,levels=c("FeCl3","EDTA","base"))
p_metalions = ggplot(df_area,aes(x=additive,y=DeferoxamineE)) +
  geom_boxplot() +
  geom_point(position = "jitter",size=3) +
  scale_y_log10(limits = c(1,1e+08)) +
  ggprism::theme_prism(base_fontface = "plain",base_family = "calibri") + 
  labs(y="DeferoxamineE \n(m/z 601.355)",
       x="Medium") + 
  facet_wrap(~medium,scales = "free")

ggsave(p_metalions,filename = "DeferoxamineE_area_metalions.svg",height=3.5,width=11)
