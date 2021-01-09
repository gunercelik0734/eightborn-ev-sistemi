furnicatalogue.ItemLookup = {}
furnicatalogue.ShopItems = {
[1]={[4]="Gardrop",[3]  =  "apa_mp_h_bed_chestdrawer_02",[1] ="Saksı",[2] =816},
[2]={[4]="Yatak",[3]  =  "apa_mp_h_bed_double_08",[1] ="Saksı2",[2] =1732},
[3]={[4]="Lamba",[3]  =  "apa_mp_h_floorlamp_b",[1] ="Saksı3",[2] =2261},
[4]={[4]="TV",[3]  =  "apa_mp_h_str_avunitm_01",[1] ="Saksı4",[2] =2287},
[5]={[4]="Fan",[3]  =  "bkr_prop_weed_fan_floor_01a",[1] ="Saksı5",[2] =702},
[6]={[4]="Terazi",[3]  =  "bkr_prop_weed_scales_01a",[1] ="Saksı6",[2] =2143},
[7]={[4]="Çanta",[3]  =  "ex_prop_adv_case_sm",[1] ="Saksı7",[2] =645},
[8]={[4]="Mermi",[3]  =  "gr_prop_gunlocker_ammo_01a",[1] ="Saksı8",[2] =1446},
[9]={[4]="Oyuncu Koltuğu",[3] = "gr_prop_highendchair_gr_01a", [2] =250, [1] = "Çanta"},
[10]={[4]="Saksı",[3] = "prop_pot_plant_05b", [2] =250, [1] = "Kolye"},
[11]={[4]="Radio",[3] = "prop_radio_01", [2] =250, [1] = "Saat"},
[12]={[4]="Neon",[3] = "prop_ragganeon", [2] =250, [1] = "Saat2"},
}

for k,v in pairs(furnicatalogue.ShopItems) do
  local model = v[3]
  local label = v[1]
  furnicatalogue.ItemLookup[label] = model
end
