library(tidyverse)
library(SRTtools)

# function
wiki.processor <- function(x){
    x %>% 
    dplyr::mutate(V1=str_replace_all(V1, "\\[.*\\]", "")) %>%
    dplyr::mutate(V1=str_replace_all(V1, "\\(.*\\)", "")) %>%
    dplyr::mutate(V1=str_replace_all(V1, "（.*）", "")) %>%
    dplyr::mutate(V1=str_replace_all(V1, "\r", "")) %>%
    #dplyr::mutate(V1=str_replace_all(V1, " ", "")) %>%
    dplyr::mutate(V1=str_replace_all(V1, "「|」|『|』|・|、|※|-|:|~|	|  ", "")) %>%
    dplyr::rename(content=V1)
}

# tachikoma from sac
sac.script.names <- dir("dat/SAC", pattern="^SAC.*txt$") %>%
    paste0("dat/SAC/",.)
data.all <- sac.script.names %>%
    purrr::map_dfr(function(x) read.csv(x, header=FALSE)) %>%
    tidyr::separate(V1, c("speaker", "content"), sep="「|」|：")
# head(data.all)
# glimpse(data.all)
write_csv(data.all, "dat/SAC_scripts.csv")

tachikoma.script.arranged <- data.all %>%
    dplyr::filter(str_detect(speaker, "^タ")) %>%
    dplyr::select(content) %>%
    dplyr::mutate(content=str_replace_all(content, "・・・", "…"))

# wikipedia
wiki.ai <- wiki.processor(read.csv("dat/wiki/wikipedia_ai.txt", header=FALSE))
write_delim(wiki.ai, "dat/wiki/wikipedia_ai_prepped.txt")

wiki.tachikoma <- wiki.processor(read.csv("dat/wiki/wikipedia_tachikoma.txt", header=FALSE))
write_delim(wiki.tachikoma, "dat/wiki/wikipedia_tachikoma_prepped.txt")

# niconico 
nico.tachikoma <- wiki.processor(read.csv("dat/wiki/nicovideo_tachikoma.txt", header=FALSE))
write_delim(nico.tachikoma, "dat/wiki/nicovideo_tachikoma_prepped.txt")

#=== data from Netflix
sac.srt <- SRTtools::srt.read("dat/SAC/攻殻機動隊 STAND ALONE COMPLEX-シーズン2-26-憂国への帰還 ENDLESS∞GIG_ja.srt")

srt.script.names <- dir("dat/SAC", pattern="^攻殻機動隊.*srt$") %>%
    paste0("dat/SAC/",.)
srt.data.all <- srt.script.names %>%
    purrr::map(function(x) srt.read(x)) %>% 
    unlist() %>% 
    enframe() %>% 
    # 半角数字から始まるのは削除
    dplyr::mutate(valid_flag = if_else(str_detect(value, "^\\d"),0,1)) %>% 
    dplyr::filter(valid_flag==1) %>% 
    # speakerとscriptを分ける
    tidyr::separate(value, c("speaker", "content"), "）", fill="left") %>% 
    # 無言除外
    dplyr::filter(content!="") %>% 
    # 最後の句点をつける
    dplyr::mutate(content=str_replace(content, "$","。")) %>% 
    # 始まり括弧抜く
    dplyr::mutate(speaker=str_replace(speaker, "（","")) %>% 
    # 話者を埋める、直前のNAでない値で
    tidyr::fill(speaker, .direction="down")
netflix.tachikoma <- srt.data.all %>% 
    dplyr::filter(str_detect(speaker, "タチコマ")) %>% 
    dplyr::select(content)
write_delim(netflix.tachikoma, "dat/sac/netflix_tachikoma_prepped.txt")

tachikoma.train <- rbind(
    tachikoma.script.arranged, 
    wiki.ai,
    wiki.tachikoma,
    nico.tachikoma,
    netflix.tachikoma
    ) %>%
    # shuffle
    dplyr::mutate(random_id=rnorm(n(),0,1)) %>%
    dplyr::arrange(random_id) %>%
    dplyr::select(-random_id)%>%
    # dplyr::summarize(content=paste0(content, collapse="")) %>%
    dplyr::mutate(content=str_to_upper(content)) %>%
    tidyr::separate_rows(., content, sep="。") %>%
    # 末尾に。をつける
    dplyr::mutate(content=str_replace_all(content, "$", "。")) %>%
    dplyr::mutate(content=str_replace_all(content, "！。", "！")) %>%
    dplyr::mutate(content=str_replace_all(content, "…。", "…")) %>%
    dplyr::mutate(content=str_replace_all(content, "？。", "？")) %>%
    dplyr::mutate(content=str_replace_all(content, "♪。", "♪")) %>%
    # 一文字消す
    dplyr::filter(nchar(content)!=1) 

tachikoma.train %>% dim()

colnames(tachikoma.train) <- ""
write_delim(tachikoma.train, "dat/tachikoma_train.txt")

# # split train - valid
# # 85:15
# colnames(tachikoma.train) <- "content"
# tachikoma.train <- tachikoma.train %>% dplyr::mutate(id = row_number())
# #Create training set
# train <- tachikoma.train %>% sample_frac(.85)
# #Create test set
# valid  <- anti_join(tachikoma.train, train, by = 'id')
# # del id
# train <- train %>% dplyr::select(-id)
# valid <- valid %>% dplyr::select(-id)
# # write
# write_delim(train, "dat/train.txt")
# write_delim(valid, "dat/valid.txt")


    