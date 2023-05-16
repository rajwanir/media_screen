#!/usr/bin/env python
# coding: utf-8
##import sys
##!{sys.executable} -m pip install opentrons
from opentrons import protocol_api
import pandas as pd
metadata = {'apiLevel': '2.13'}
protocol_template=pd.read_csv("ot2_media_template.csv")
protocol_template=protocol_template[protocol_template.plate.isin(['P1','P2','P3','P4','P5','P6','P7'])]
# In[55]:


def run(protocol: protocol_api.ProtocolContext):
    #assinging plates
    plates = {}
    plates['p1'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 1)
    plates['p2'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 2)
    plates['p3'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 3)
    plates['p4'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 4)
    plates['p5'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 5)
    plates['p6'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 6)
    plates['p7'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 7)
    
    
    #assing stock components
    stock_rack = protocol.load_labware('opentrons_24_tuberack_generic_2ml_screwcap', 9)
    glucose = stock_rack.wells_by_name()['A1']
    k2hpo4 = stock_rack.wells_by_name()['A2']
    mgso4 = stock_rack.wells_by_name()['A3']
    nacl = stock_rack.wells_by_name()['A5']
    aspargine = stock_rack.wells_by_name()['B1']
    glycerol = stock_rack.wells_by_name()['B2']
    yeast_extract = stock_rack.wells_by_name()['B3']
    malt_extract = stock_rack.wells_by_name()['B4']
    beef_extract = stock_rack.wells_by_name()['B5']
    n_z_amine = stock_rack.wells_by_name()['C1']
    peptone = stock_rack.wells_by_name()['C2']
    
    
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

    components_loc = []
    for comp in protocol_template['ot2_label'].tolist():
        components_loc.append(components[comp])
    
    #water reservoir
    water = protocol.load_labware('nest_1_reservoir_195ml', 8)
    
    #loading tipracks and pipettes
    p20_tiprack = protocol.load_labware('opentrons_96_tiprack_20ul', 10)
    p1000_tiprack = protocol.load_labware('opentrons_96_tiprack_1000ul', 11)
    p20 = protocol.load_instrument('p20_single_gen2', 'right', tip_racks=[p20_tiprack])
    p1000 = protocol.load_instrument('p1000_single_gen2', 'left', tip_racks=[p1000_tiprack])
    
    for p in ['p1','p2','p3','p4','p5','p6','p7']:
        #add water
        p1000.distribute(volume = 190, source = water.wells()[0], dest = [plates[p].wells_by_name()[well_name] for well_name in list(set(protocol_template['well'].tolist()))])
        #add components
        p20.transfer(volume = protocol_template['vol'].tolist(), 
                 source=components_loc,
                 dest = [plates[p].wells_by_name()[well_name] for well_name in protocol_template['well'].tolist()])
        
        

