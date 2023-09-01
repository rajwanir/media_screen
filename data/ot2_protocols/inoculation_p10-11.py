#!/usr/bin/env python
# coding: utf-8

# In[1]:


from opentrons import protocol_api
import pandas as pd
metadata = {'apiLevel': '2.13'}
taget_plates = ['P10','P11']


# In[13]:


all_wells=['A1', 'A10', 'A11', 'A12', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'B1', 'B10', 'B11', 'B12', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'C1', 'C10', 'C11', 'C12', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'D1', 'D10', 'D11', 'D12', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'E1', 'E10', 'E11', 'E12', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'F1', 'F10', 'F11', 'F12', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'G1', 'G10', 'G11', 'G12', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9', 'H1', 'H10', 'H11', 'H12', 'H2', 'H3', 'H4', 'H5', 'H6', 'H7', 'H8', 'H9']


# In[10]:


def run(protocol: protocol_api.ProtocolContext):
    
    #loading tipracks and pipettes
    p20_tiprack = protocol.load_labware('opentrons_96_tiprack_20ul', 1)
    p20 = protocol.load_instrument('p20_single_gen2', 'left', tip_racks=[p20_tiprack])
    
    
    #assinging plates
    plates = {}
    # plates['P1'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 3)
    # plates['P2'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 4)
    # plates['P3'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 5)
    # plates['P4'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 6)
    # plates['P5'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 7)
    # plates['P6'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 8)
    # plates['P7'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 9)
    # plates['P8'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 10)
    # plates['P9'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 11)
    plates['P10'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 3)
    plates['P11'] = protocol.load_labware('corning_96_wellplate_360ul_flat', 4)
    
    #assin incoulum
    stock_rack = protocol.load_labware('opentrons_24_tuberack_generic_2ml_screwcap', 2)
    seed_culture = stock_rack.wells_by_name()['D6']
    
    for p in taget_plates:
        #add water
        p20.distribute(volume = 1,
                         source = seed_culture,
                         dest = [plates[p].wells_by_name()[well_name] for well_name in all_wells])

