#!/usr/bin/env python
# coding: utf-8

# In[1]:


##import sys
##!{sys.executable} -m pip install opentrons
from opentrons import protocol_api
import pandas as pd
metadata = {'apiLevel': '2.13'}
plate_type = "corning_96_wellplate_360ul_flat" # or thermoscientificnunc_96_wellplate_2000ul
stock_holder = "thermoscientificnunc_96_wellplate_2000ul" # or opentrons_24_tuberack_generic_2ml_screwcap
target_plates='P1'
scale=1
#protocol_template=pd.read_csv("ot2_media_template.csv")
##protocol_template=protocol_template[protocol_template.plate.isin(['P1','P2','P3','P4','P5','P6','P7'])]


# In[7]:


protocol_template ={'plate':['P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1','P1'],
'well':['A1','B1','C1','D1','E1','F1','G1','H1','A1','B1','C1','D1','E1','F1','G1','H1','A1','B1','C1','D1','E1','F1','G1','H1','C4','C4','C4','C4','B4','B4','B4','B4','E4','E4','E4','E4','G4','G4','G4','G4','G4','F4','F4','F4','F4','D4','D4','D4','D4','D4','D4','A4','A4','A4','A4','A4','A4','H4','H4','H4','H4','H4','H4','A2','B2','C2','D2','E2','F2','G2','H2','A2','B2','C2','D2','E2','F2','G2','H2','A2','B2','C2','D2','E2','F2','G2','H2','A2','B2','C2','D2','E2','F2','G2','H2','A2','B2','C2','D2','E2','F2','G2','H2','A2','B2','C2','D2','E2','F2','G2','H2','A3','B3','C3','D3','E3','F3','G3','H3','A3','B3','C3','D3','E3','F3','G3','H3','A3','B3','C3','D3','E3','F3','G3','H3','A3','B3','C3','D3','E3','F3','G3','H3','A3','B3','C3','D3','E3','F3','G3','H3'],
'ot2_label':['k2hpo4','k2hpo4','k2hpo4','k2hpo4','k2hpo4','k2hpo4','k2hpo4','k2hpo4','yeast_extract','yeast_extract','yeast_extract','yeast_extract','yeast_extract','yeast_extract','yeast_extract','yeast_extract','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','peptone','k2hpo4','nacl','n_z_amine','glucose','peptone','k2hpo4','n_z_amine','peptone','malt_extract','nacl','l_asparagine','glucose','peptone','malt_extract','mgso4_x_7_h2o','l_asparagine','peptone','malt_extract','mgso4_x_7_h2o','glycerol','glucose','peptone','k2hpo4','l_asparagine','yeast_extract','n_z_amine','glucose','malt_extract','k2hpo4','l_asparagine','yeast_extract','n_z_amine','glucose','peptone','malt_extract','mgso4_x_7_h2o','glycerol','yeast_extract','glucose','glucose','glucose','glucose','glucose','glucose','glucose','glucose','peptone','peptone','peptone','peptone','peptone','peptone','peptone','peptone','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','mgso4_x_7_h2o','l_asparagine','l_asparagine','l_asparagine','l_asparagine','l_asparagine','l_asparagine','l_asparagine','l_asparagine','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','glycerol','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','beef_extract','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine','n_z_amine'],
'vol':[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,4,2,2,2,4,2,4,2,2,2,2,4,2,2,4,2,2,4,2,2,2,4,2,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]}

protocol_template=pd.DataFrame(data=protocol_template)
all_wells = list(set(protocol_template.well.tolist()))
protocol_template.vol = protocol_template.vol * scale


# In[ ]:


def run(protocol: protocol_api.ProtocolContext):
    #assinging plates
    plates = {}
    plates['P1'] = protocol.load_labware(plate_type, 5)
    
    #assing stock components
    stock_rack = protocol.load_labware(stock_holder, 2)
    glucose = stock_rack.wells_by_name()['A1']
    k2hpo4 = stock_rack.wells_by_name()['A2']
    mgso4 = stock_rack.wells_by_name()['A3']
    nacl = stock_rack.wells_by_name()['A4']
    aspargine = stock_rack.wells_by_name()['A5']
    glycerol = stock_rack.wells_by_name()['A6']
    yeast_extract = stock_rack.wells_by_name()['B1']
    malt_extract = stock_rack.wells_by_name()['B2']
    beef_extract = stock_rack.wells_by_name()['B3']
    n_z_amine = stock_rack.wells_by_name()['B4']
    peptone = stock_rack.wells_by_name()['B5']
    
    
    components = {}
    components["glucose"] = glucose
    components["k2hpo4"] = k2hpo4
    components["mgso4_x_7_h2o"] = mgso4
    components["nacl"] = nacl
    components["l_asparagine"] = aspargine
    components["glycerol"] = glycerol
    components["yeast_extract"] = yeast_extract
    components["malt_extract"] = malt_extract
    components["beef_extract"] = beef_extract
    components["n_z_amine"] = n_z_amine
    components["peptone"] = peptone
    
    component_names=list(components.keys())

    
    components_loc = []
    for comp in protocol_template['ot2_label'].tolist():
        components_loc.append(components[comp])
    
    #water reservoir
    water = protocol.load_labware('nest_1_reservoir_195ml', 4)
    
    #loading tipracks and pipettes
    p20_tiprack = protocol.load_labware('opentrons_96_tiprack_20ul', 3)
    p1000_tiprack = protocol.load_labware('opentrons_96_tiprack_1000ul', 1)
    p20 = protocol.load_instrument('p20_single_gen2', 'left', tip_racks=[p20_tiprack])
    p1000 = protocol.load_instrument('p1000_single_gen2', 'right', tip_racks=[p1000_tiprack])
    
   # for p in target_plates:
    p= 'P1'
    ##add water
    p1000.distribute(volume = 190*scale,
                     source = water.wells()[0],
                     dest = [plates[p].wells_by_name()[well_name] for well_name in list(set(protocol_template['well'].tolist()))])
    ##add components, changing tips between components
    for c in component_names:
        component_indices=protocol_template.index[(protocol_template.ot2_label==c) & (protocol_template.plate==p)].tolist()
        trans_volumes = protocol_template[protocol_template.index.isin(component_indices)].vol.tolist() 
        dest_wells = protocol_template[protocol_template.index.isin(component_indices)].well.tolist()
        if len(list(filter(None, dest_wells))) == 0:
             continue
        p20.transfer(volume = trans_volumes,
                     source=components[c],
                     touch_tip=True,
                     dest = [plates[p].wells_by_name()[well_name] for well_name in dest_wells])
    ## inoculate
    seed_culture = stock_rack.wells_by_name()['D6']
    p20.distribute(volume = 1,
                         source = seed_culture,
                         dest = [plates[p].wells_by_name()[well_name] for well_name in all_wells])

