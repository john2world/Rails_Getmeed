db.users.ensureIndex({handle: 1})
db.feed_items.ensureIndex({poster_type: 1})
db.feed_items.ensureIndex({type: 1})
db.feed_items.dropIndex("feed_key_1")
db.feed_items.dropIndex("privacy_1")
db.schools.insert({
                      _id: "getmeed",
                      handle: "getmeed",
                      name: "Meed",
                      logo: "https://res.cloudinary.com/resume/image/upload/c_scale,w_120/v1427155934/crescent_green_rt6rit.png"
                  })

db.schools.insert({
                      _id: "umich",
                      handle: "umich",
                      name: "University of Michigan",
                      logo: "http://res.cloudinary.com/resume/image/upload/c_scale,w_180/v1408821782/https_coursera-university-assets_s3_amazonaws_com_70_de505d47be7d3a063b51b6f856a6e2_New-Block-M-Stacked-Blue-295C_600x600_s6daju.png"
                  })

db.schools.insert({
                      _id: "minerva",
                      handle: "minerva",
                      name: "Minerva Project",
                      logo: "https://res.cloudinary.com/resume/image/upload/c_scale,w_100/v1433966444/minerva_logo_square_wexqnq.png"
                  })


db.schools.insert({
                      _id: "ucsd",
                      handle: "ucsd",
                      name: "University of California, San Diego",
                      logo: "http://res.cloudinary.com/resume/image/upload/v1408823721/http_businessofcollegesports_com_wp-content_uploads_2012_03_ucsd-tritons_g61uxy.jpg"
                  })

db.schools.insert({
                      _id: "uci",
                      handle: "uci",
                      name: "University of California, Irvine",
                      logo: "https://res.cloudinary.com/resume/image/upload/c_scale,w_200/v1424750127/http_socialcomputing.uci.edu_sites_default_files_logos_uci_j6upda.jpg"
                  })


db.schools.insert({
                      _id: "uwaterloo",
                      handle: "uwaterloo",
                      name: "University of Waterloo",
                      logo: "http://res.cloudinary.com/resume/image/upload/v1408822710/http_i_imgur_com_g0kdB1T_jqrhzr.jpg"
                  })

db.schools.update({"_id" : "usc"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403398763/https_fbcdn-sphotos-e-a_akamaihd_net_hphotos-ak-xaf1_t1_0-9_10247472_784138694943918_2566252489225535785_n_pn7zvj.jpg"}});
db.schools.update({"_id" : "ucla"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403398541/https_fbcdn-sphotos-b-a_akamaihd_net_hphotos-ak-xpa1_t1_0-9_10291852_10152192154145958_3670918893082090246_n_fy6vb5.png"}});
db.schools.update({"_id" : "berkeley"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403398946/https_scontent-a_xx_fbcdn_net_hphotos-xpa1_t1_0-9_10154268_10152324234159661_7811345513940021516_n_jcpbot.jpg"}});
db.schools.update({"_id" : "ufl"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399006/https_fbcdn-sphotos-c-a_akamaihd_net_hphotos-ak-xap1_t1_0-9_1511295_10151884909689632_1673995846_n_vfuu7l.jpg"}});
db.schools.update({"_id" : "northwestern"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399242/http_mastersinhealthinformatics_com_wp-content_uploads_2011_11_Northwestern-University-Logo_lo2yaw.jpg"}});
db.schools.update({"_id" : "stanford"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399300/https_fbcdn-sphotos-f-a_akamaihd_net_hphotos-ak-xfa1_t1_0-9_1044164_10151662970763418_1682551420_n_btnjgf.png"}});
db.schools.update({"_id" : "mit"}, { $set : {"logo": "https://res.cloudinary.com/resume/image/upload/v1403399344/https_fbcdn-sphotos-b-a_akamaihd_net_hphotos-ak-xaf1_t1_0-9_1148800_680835795293388_126913444_n_ieenqc.png"}});
db.schools.update({"_id" : "usc"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403398763/https_fbcdn-sphotos-e-a_akamaihd_net_hphotos-ak-xaf1_t1_0-9_10247472_784138694943918_2566252489225535785_n_pn7zvj.jpg"}});
db.schools.update({"_id" : "rice"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399502/https_fbcdn-sphotos-e-a_akamaihd_net_hphotos-ak-xap1_t1_0-9_1497662_10152559597990550_2006972615_n_aabclv.jpg"}});
db.schools.update({"_id" : "brown"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399588/https_scontent-b_xx_fbcdn_net_hphotos-xfp1_t1_0-9_1977299_10151885273256534_1030627330_n_x6zng7.png"}});
db.schools.update({"_id" : "duke"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399750/https_scontent-b_xx_fbcdn_net_hphotos-xfa1_t1_0-9_423332_10150531052446475_2102094817_n_bv2rgq.jpg"}});
db.schools.update({"_id" : "harvard"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399806/https_scontent-a_xx_fbcdn_net_hphotos-xaf1_t31_0-8_10380039_10152049890301607_8853146182777969742_o_jopvij.png"}});
db.schools.update({"_id" : "columbia"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399928/https_scontent-a_xx_fbcdn_net_hphotos-xfa1_t1_0-9_4852_107717938936_1288057_n_n90jh3.jpg"}});
db.schools.update({"_id" : "cmu"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403399864/https_fbcdn-sphotos-g-a_akamaihd_net_hphotos-ak-xpa1_t1_0-9_1461114_10152120743001388_97498385_n_s1ihik.png"}});
db.schools.update({"_id" : "nyu"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403400049/https_fbcdn-sphotos-f-a_akamaihd_net_hphotos-ak-prn2_t1_0-9_552699_10151136829178689_449718517_n_ldlnva.jpg"}});
db.schools.update({"_id" : "yale"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403400096/https_scontent-a_xx_fbcdn_net_hphotos-xfp1_t1_0-9_227563_10150253568700320_5332225_n_lb5zkb.jpg"}});
db.schools.update({"_id" : "uw"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403400161/https_fbcdn-sphotos-g-a_akamaihd_net_hphotos-ak-frc1_t1_0-9_285709_10150894511456274_1637082454_n_zgbwaa.jpg"}});
db.schools.update({"_id" : "upenn"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403419404/http_upload_wikimedia_org_wikipedia_commons_thumb_9_92_UPenn_shield_with_banner_svg_250px-UPenn_shield_with_banner_svg_hfilnr.png"}});
db.schools.update({"_id" : "umass"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403419486/https_fbcdn-sphotos-b-a_akamaihd_net_hphotos-ak-frc3_t1_0-9_995570_10151865306493671_1168153659_n_xklypd.png"}});
db.schools.update({"_id" : "utexas"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1403419799/https_fbcdn-sphotos-h-a_akamaihd_net_hphotos-ak-ash2_t1_0-9_551193_10150970949386930_1041310064_n_rivqnl.jpg"}});

db.schools.update({"_id" : "caltech"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1418070519/http_www_caltech_edu_sites_all_themes_caltech_mte_img_caltech_logo_ypkjoo.jpg"}});
db.schools.update({"_id" : "cornell"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1418070742/https_lh3_googleusercontent_com_-2jofGt-kQZk_AAAAAAAAAAI_AAAAAAAAKG8_AEw24vbiblA_s120-c_photo_bnhf4c.png"}});
db.schools.update({"_id" : "gatech"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1418070800/https_lh5_googleusercontent_com_-q0gRK-mwssI_AAAAAAAAAAI_AAAAAAAACsY_ZDo-TbmjMT8_s120-c_photo_g3dhbh.jpg"}});
db.schools.update({"_id" : "illinois"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1418070841/http_t3_gstatic_com_images_q_tbn_ANd9GcSM9Eu2Fw1ahuF4hXShslBAk2ZbWxvesSKlbCVckNXGLb3z73VXKg_non4yv.jpg"}});
db.schools.update({"_id" : "princeton"}, { $set : {"logo": "http://res.cloudinary.com/resume/image/upload/v1418070899/https_lh4_googleusercontent_com_-eJ6mEvslTq8_AAAAAAAAAAI_AAAAAAAAA7s_IWNb8J2dy80_s120-c_photo_ftlvjr.png"}});




db.schools.insert([

                      {
                          _id: "ufl",
                          handle: "ufl",
                          name: "University of Florida"
                      },
                      {
                          _id: "northwestern",
                          handle: "northwestern",
                          name: "Northwestern University"
                      },
                      {
                          _id: "berkeley",
                          handle: "berkeley",
                          name: "University of California, Berkeley"
                      },
                      {
                          _id: "caltech",
                          handle: "caltech",
                          name: "California Institute of Technology"
                      },
                      {
                          _id: "stanford",
                          handle: "stanford",
                          name: "Stanford University"
                      },
                      {
                          _id: "mit",
                          handle: "mit",
                          name: "Massachusetts Institute of Technology"
                      },
                      {
                          _id: "usc",
                          handle: "usc",
                          name: "University of Southern California"
                      },
                      {
                          _id: "ucla",
                          handle: "ucla",
                          name: "University of California, Los Angeles"
                      },
                      {
                          _id: "utexas",
                          handle: "utexas",
                          name: "The University of Texas At Austin"
                      },
                      {
                          _id: "gatech",
                          handle: "gatech",
                          name: "Georgia Institute of Technology"
                      },
                      {
                          _id: "illinois",
                          handle: "illinois",
                          name: "University of Illinois, Urbana-Champaign"
                      },
                      {
                          _id: "rice",
                          handle: "rice",
                          name: "Rice University"
                      },
                      {
                          _id: "brown",
                          handle: "brown",
                          name: "Brown University"
                      },
                      {
                          _id: "duke",
                          handle: "duke",
                          name: "Duke University"
                      },
                      {
                          _id: "harvard",
                          handle: "harvard",
                          name: "Harvard University"
                      },
                      {
                          _id: "cmu",
                          handle: "cmu",
                          name: "Carnegie Mellon University"
                      },
                      {
                          _id: "columbia",
                          handle: "columbia",
                          name: "Columbia University"
                      },
                      {
                          _id: "nyu",
                          handle: "nyu",
                          name: "New York University"
                      },
                      {
                          _id: "yale",
                          handle: "yale",
                          name: "Yale University"
                      },
                      {
                          _id: "uw",
                          handle: "uw",
                          name: "University of Washington"
                      },
                      {
                          _id: "princeton",
                          handle: "princeton",
                          name: "Princeton University"
                      },
                      {
                          _id: "upenn",
                          handle: "upenn",
                          name: "University of Pennsylvania"
                      },
                      {
                          _id: "cornell",
                          handle: "cornell",
                          name: "Cornell University"
                      },
                      {
                          _id: "umass",
                          handle: "umass",
                          name: "University of Massachusetts Amherst"
                      }

                  ]);