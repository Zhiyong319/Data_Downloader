import gdown

#### the emis folder
#url = 'https://drive.google.com/drive/folders/1s0D87esI8vbtSky_IMPlZKagslkMHoTu?usp=share_link'
#gdown.download_folder(url, quiet=True, use_cookies=False)

#### files in the emis folder
#url = 'https://drive.google.com/file/d/1sM-INtgFymEIpaGnAyCJrrx4TxDmsyj4'
#output = "D:/EQUATES/CMAQ_12US1/INPUT/2019/icbc/BCON_CONC_12US1_CMAQv53_TS_108NHEMI_regrid_201901.nc"
#gdown.download(url, output, quiet=False, fuzzy=True)

#id = "1EkCXGwjjMnSarTnUBO3A3H6r8R-Hgxer"
#gdown.download(id=id, output=output, quiet=False)

id = "1MdVFF077PiupheZ-6E_VQd92b_kvER1i"
output = "C:/Users/zwu/wrfout/model_ready_emis_2019_merged_nobeis_norwc_02_EQUATES_v1.0.tar"
#output = "D:/EQUATES/CMAQ_12US1/INPUT/2019/icbc/BCON_CONC_12US1_CMAQv53_TS_108NHEMI_regrid_201902.nc"
gdown.download(id=id, output=output, quiet=False)


