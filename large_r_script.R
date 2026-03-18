# Auto-generated realistic R script for testing R -> Python conversion
library(dplyr)
library(ggplot2)
set.seed(42)

# Data Generation
sales_data <- data.frame(
  id = 1:1000,
  sales_amount = runif(1000, 100, 1000),
  category = sample(c('A','B','C','D'), 1000, replace=TRUE),
  region = sample(c('North','South','East','West'), 1000, replace=TRUE)
)

# ---- Transformation Block 1 ----
sales_data <- sales_data %>%
  mutate(flag_1 = ifelse(id %% 2 == 0, 1, 0)) %>%
  mutate(adj_sales_1 = sales_amount * 1 * 0.05)

summary_1 <- sales_data %>%
  group_by(flag_1) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_1)
  )

print(paste('Summary Block 1'))
print(summary_1)

# ---- Transformation Block 2 ----
sales_data <- sales_data %>%
  mutate(flag_2 = ifelse(id %% 3 == 0, 1, 0)) %>%
  mutate(adj_sales_2 = sales_amount * 2 * 0.05)

summary_2 <- sales_data %>%
  group_by(flag_2) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_2)
  )

print(paste('Summary Block 2'))
print(summary_2)

# ---- Transformation Block 3 ----
sales_data <- sales_data %>%
  mutate(flag_3 = ifelse(id %% 4 == 0, 1, 0)) %>%
  mutate(adj_sales_3 = sales_amount * 3 * 0.05)

summary_3 <- sales_data %>%
  group_by(flag_3) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_3)
  )

print(paste('Summary Block 3'))
print(summary_3)

# ---- Transformation Block 4 ----
sales_data <- sales_data %>%
  mutate(flag_4 = ifelse(id %% 5 == 0, 1, 0)) %>%
  mutate(adj_sales_4 = sales_amount * 4 * 0.05)

summary_4 <- sales_data %>%
  group_by(flag_4) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_4)
  )

print(paste('Summary Block 4'))
print(summary_4)

# ---- Transformation Block 5 ----
sales_data <- sales_data %>%
  mutate(flag_5 = ifelse(id %% 6 == 0, 1, 0)) %>%
  mutate(adj_sales_5 = sales_amount * 5 * 0.05)

summary_5 <- sales_data %>%
  group_by(flag_5) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_5)
  )

print(paste('Summary Block 5'))
print(summary_5)

# ---- Transformation Block 6 ----
sales_data <- sales_data %>%
  mutate(flag_6 = ifelse(id %% 7 == 0, 1, 0)) %>%
  mutate(adj_sales_6 = sales_amount * 6 * 0.05)

summary_6 <- sales_data %>%
  group_by(flag_6) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_6)
  )

print(paste('Summary Block 6'))
print(summary_6)

# ---- Transformation Block 7 ----
sales_data <- sales_data %>%
  mutate(flag_7 = ifelse(id %% 8 == 0, 1, 0)) %>%
  mutate(adj_sales_7 = sales_amount * 7 * 0.05)

summary_7 <- sales_data %>%
  group_by(flag_7) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_7)
  )

print(paste('Summary Block 7'))
print(summary_7)

# ---- Transformation Block 8 ----
sales_data <- sales_data %>%
  mutate(flag_8 = ifelse(id %% 9 == 0, 1, 0)) %>%
  mutate(adj_sales_8 = sales_amount * 8 * 0.05)

summary_8 <- sales_data %>%
  group_by(flag_8) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_8)
  )

print(paste('Summary Block 8'))
print(summary_8)

# ---- Transformation Block 9 ----
sales_data <- sales_data %>%
  mutate(flag_9 = ifelse(id %% 10 == 0, 1, 0)) %>%
  mutate(adj_sales_9 = sales_amount * 9 * 0.05)

summary_9 <- sales_data %>%
  group_by(flag_9) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_9)
  )

print(paste('Summary Block 9'))
print(summary_9)

# ---- Transformation Block 10 ----
sales_data <- sales_data %>%
  mutate(flag_10 = ifelse(id %% 11 == 0, 1, 0)) %>%
  mutate(adj_sales_10 = sales_amount * 10 * 0.05)

summary_10 <- sales_data %>%
  group_by(flag_10) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_10)
  )

print(paste('Summary Block 10'))
print(summary_10)

# ---- Transformation Block 11 ----
sales_data <- sales_data %>%
  mutate(flag_11 = ifelse(id %% 12 == 0, 1, 0)) %>%
  mutate(adj_sales_11 = sales_amount * 11 * 0.05)

summary_11 <- sales_data %>%
  group_by(flag_11) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_11)
  )

print(paste('Summary Block 11'))
print(summary_11)

# ---- Transformation Block 12 ----
sales_data <- sales_data %>%
  mutate(flag_12 = ifelse(id %% 13 == 0, 1, 0)) %>%
  mutate(adj_sales_12 = sales_amount * 12 * 0.05)

summary_12 <- sales_data %>%
  group_by(flag_12) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_12)
  )

print(paste('Summary Block 12'))
print(summary_12)

# ---- Transformation Block 13 ----
sales_data <- sales_data %>%
  mutate(flag_13 = ifelse(id %% 14 == 0, 1, 0)) %>%
  mutate(adj_sales_13 = sales_amount * 13 * 0.05)

summary_13 <- sales_data %>%
  group_by(flag_13) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_13)
  )

print(paste('Summary Block 13'))
print(summary_13)

# ---- Transformation Block 14 ----
sales_data <- sales_data %>%
  mutate(flag_14 = ifelse(id %% 15 == 0, 1, 0)) %>%
  mutate(adj_sales_14 = sales_amount * 14 * 0.05)

summary_14 <- sales_data %>%
  group_by(flag_14) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_14)
  )

print(paste('Summary Block 14'))
print(summary_14)

# ---- Transformation Block 15 ----
sales_data <- sales_data %>%
  mutate(flag_15 = ifelse(id %% 16 == 0, 1, 0)) %>%
  mutate(adj_sales_15 = sales_amount * 15 * 0.05)

summary_15 <- sales_data %>%
  group_by(flag_15) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_15)
  )

print(paste('Summary Block 15'))
print(summary_15)

# ---- Transformation Block 16 ----
sales_data <- sales_data %>%
  mutate(flag_16 = ifelse(id %% 17 == 0, 1, 0)) %>%
  mutate(adj_sales_16 = sales_amount * 16 * 0.05)

summary_16 <- sales_data %>%
  group_by(flag_16) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_16)
  )

print(paste('Summary Block 16'))
print(summary_16)

# ---- Transformation Block 17 ----
sales_data <- sales_data %>%
  mutate(flag_17 = ifelse(id %% 18 == 0, 1, 0)) %>%
  mutate(adj_sales_17 = sales_amount * 17 * 0.05)

summary_17 <- sales_data %>%
  group_by(flag_17) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_17)
  )

print(paste('Summary Block 17'))
print(summary_17)

# ---- Transformation Block 18 ----
sales_data <- sales_data %>%
  mutate(flag_18 = ifelse(id %% 19 == 0, 1, 0)) %>%
  mutate(adj_sales_18 = sales_amount * 18 * 0.05)

summary_18 <- sales_data %>%
  group_by(flag_18) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_18)
  )

print(paste('Summary Block 18'))
print(summary_18)

# ---- Transformation Block 19 ----
sales_data <- sales_data %>%
  mutate(flag_19 = ifelse(id %% 20 == 0, 1, 0)) %>%
  mutate(adj_sales_19 = sales_amount * 19 * 0.05)

summary_19 <- sales_data %>%
  group_by(flag_19) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_19)
  )

print(paste('Summary Block 19'))
print(summary_19)

# ---- Transformation Block 20 ----
sales_data <- sales_data %>%
  mutate(flag_20 = ifelse(id %% 21 == 0, 1, 0)) %>%
  mutate(adj_sales_20 = sales_amount * 20 * 0.05)

summary_20 <- sales_data %>%
  group_by(flag_20) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_20)
  )

print(paste('Summary Block 20'))
print(summary_20)

# ---- Transformation Block 21 ----
sales_data <- sales_data %>%
  mutate(flag_21 = ifelse(id %% 22 == 0, 1, 0)) %>%
  mutate(adj_sales_21 = sales_amount * 21 * 0.05)

summary_21 <- sales_data %>%
  group_by(flag_21) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_21)
  )

print(paste('Summary Block 21'))
print(summary_21)

# ---- Transformation Block 22 ----
sales_data <- sales_data %>%
  mutate(flag_22 = ifelse(id %% 23 == 0, 1, 0)) %>%
  mutate(adj_sales_22 = sales_amount * 22 * 0.05)

summary_22 <- sales_data %>%
  group_by(flag_22) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_22)
  )

print(paste('Summary Block 22'))
print(summary_22)

# ---- Transformation Block 23 ----
sales_data <- sales_data %>%
  mutate(flag_23 = ifelse(id %% 24 == 0, 1, 0)) %>%
  mutate(adj_sales_23 = sales_amount * 23 * 0.05)

summary_23 <- sales_data %>%
  group_by(flag_23) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_23)
  )

print(paste('Summary Block 23'))
print(summary_23)

# ---- Transformation Block 24 ----
sales_data <- sales_data %>%
  mutate(flag_24 = ifelse(id %% 25 == 0, 1, 0)) %>%
  mutate(adj_sales_24 = sales_amount * 24 * 0.05)

summary_24 <- sales_data %>%
  group_by(flag_24) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_24)
  )

print(paste('Summary Block 24'))
print(summary_24)

# ---- Transformation Block 25 ----
sales_data <- sales_data %>%
  mutate(flag_25 = ifelse(id %% 26 == 0, 1, 0)) %>%
  mutate(adj_sales_25 = sales_amount * 25 * 0.05)

summary_25 <- sales_data %>%
  group_by(flag_25) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_25)
  )

print(paste('Summary Block 25'))
print(summary_25)

# ---- Transformation Block 26 ----
sales_data <- sales_data %>%
  mutate(flag_26 = ifelse(id %% 27 == 0, 1, 0)) %>%
  mutate(adj_sales_26 = sales_amount * 26 * 0.05)

summary_26 <- sales_data %>%
  group_by(flag_26) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_26)
  )

print(paste('Summary Block 26'))
print(summary_26)

# ---- Transformation Block 27 ----
sales_data <- sales_data %>%
  mutate(flag_27 = ifelse(id %% 28 == 0, 1, 0)) %>%
  mutate(adj_sales_27 = sales_amount * 27 * 0.05)

summary_27 <- sales_data %>%
  group_by(flag_27) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_27)
  )

print(paste('Summary Block 27'))
print(summary_27)

# ---- Transformation Block 28 ----
sales_data <- sales_data %>%
  mutate(flag_28 = ifelse(id %% 29 == 0, 1, 0)) %>%
  mutate(adj_sales_28 = sales_amount * 28 * 0.05)

summary_28 <- sales_data %>%
  group_by(flag_28) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_28)
  )

print(paste('Summary Block 28'))
print(summary_28)

# ---- Transformation Block 29 ----
sales_data <- sales_data %>%
  mutate(flag_29 = ifelse(id %% 30 == 0, 1, 0)) %>%
  mutate(adj_sales_29 = sales_amount * 29 * 0.05)

summary_29 <- sales_data %>%
  group_by(flag_29) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_29)
  )

print(paste('Summary Block 29'))
print(summary_29)

# ---- Transformation Block 30 ----
sales_data <- sales_data %>%
  mutate(flag_30 = ifelse(id %% 31 == 0, 1, 0)) %>%
  mutate(adj_sales_30 = sales_amount * 30 * 0.05)

summary_30 <- sales_data %>%
  group_by(flag_30) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_30)
  )

print(paste('Summary Block 30'))
print(summary_30)

# ---- Transformation Block 31 ----
sales_data <- sales_data %>%
  mutate(flag_31 = ifelse(id %% 32 == 0, 1, 0)) %>%
  mutate(adj_sales_31 = sales_amount * 31 * 0.05)

summary_31 <- sales_data %>%
  group_by(flag_31) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_31)
  )

print(paste('Summary Block 31'))
print(summary_31)

# ---- Transformation Block 32 ----
sales_data <- sales_data %>%
  mutate(flag_32 = ifelse(id %% 33 == 0, 1, 0)) %>%
  mutate(adj_sales_32 = sales_amount * 32 * 0.05)

summary_32 <- sales_data %>%
  group_by(flag_32) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_32)
  )

print(paste('Summary Block 32'))
print(summary_32)

# ---- Transformation Block 33 ----
sales_data <- sales_data %>%
  mutate(flag_33 = ifelse(id %% 34 == 0, 1, 0)) %>%
  mutate(adj_sales_33 = sales_amount * 33 * 0.05)

summary_33 <- sales_data %>%
  group_by(flag_33) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_33)
  )

print(paste('Summary Block 33'))
print(summary_33)

# ---- Transformation Block 34 ----
sales_data <- sales_data %>%
  mutate(flag_34 = ifelse(id %% 35 == 0, 1, 0)) %>%
  mutate(adj_sales_34 = sales_amount * 34 * 0.05)

summary_34 <- sales_data %>%
  group_by(flag_34) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_34)
  )

print(paste('Summary Block 34'))
print(summary_34)

# ---- Transformation Block 35 ----
sales_data <- sales_data %>%
  mutate(flag_35 = ifelse(id %% 36 == 0, 1, 0)) %>%
  mutate(adj_sales_35 = sales_amount * 35 * 0.05)

summary_35 <- sales_data %>%
  group_by(flag_35) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_35)
  )

print(paste('Summary Block 35'))
print(summary_35)

# ---- Transformation Block 36 ----
sales_data <- sales_data %>%
  mutate(flag_36 = ifelse(id %% 37 == 0, 1, 0)) %>%
  mutate(adj_sales_36 = sales_amount * 36 * 0.05)

summary_36 <- sales_data %>%
  group_by(flag_36) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_36)
  )

print(paste('Summary Block 36'))
print(summary_36)

# ---- Transformation Block 37 ----
sales_data <- sales_data %>%
  mutate(flag_37 = ifelse(id %% 38 == 0, 1, 0)) %>%
  mutate(adj_sales_37 = sales_amount * 37 * 0.05)

summary_37 <- sales_data %>%
  group_by(flag_37) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_37)
  )

print(paste('Summary Block 37'))
print(summary_37)

# ---- Transformation Block 38 ----
sales_data <- sales_data %>%
  mutate(flag_38 = ifelse(id %% 39 == 0, 1, 0)) %>%
  mutate(adj_sales_38 = sales_amount * 38 * 0.05)

summary_38 <- sales_data %>%
  group_by(flag_38) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_38)
  )

print(paste('Summary Block 38'))
print(summary_38)

# ---- Transformation Block 39 ----
sales_data <- sales_data %>%
  mutate(flag_39 = ifelse(id %% 40 == 0, 1, 0)) %>%
  mutate(adj_sales_39 = sales_amount * 39 * 0.05)

summary_39 <- sales_data %>%
  group_by(flag_39) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_39)
  )

print(paste('Summary Block 39'))
print(summary_39)

# ---- Transformation Block 40 ----
sales_data <- sales_data %>%
  mutate(flag_40 = ifelse(id %% 41 == 0, 1, 0)) %>%
  mutate(adj_sales_40 = sales_amount * 40 * 0.05)

summary_40 <- sales_data %>%
  group_by(flag_40) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_40)
  )

print(paste('Summary Block 40'))
print(summary_40)

# ---- Transformation Block 41 ----
sales_data <- sales_data %>%
  mutate(flag_41 = ifelse(id %% 42 == 0, 1, 0)) %>%
  mutate(adj_sales_41 = sales_amount * 41 * 0.05)

summary_41 <- sales_data %>%
  group_by(flag_41) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_41)
  )

print(paste('Summary Block 41'))
print(summary_41)

# ---- Transformation Block 42 ----
sales_data <- sales_data %>%
  mutate(flag_42 = ifelse(id %% 43 == 0, 1, 0)) %>%
  mutate(adj_sales_42 = sales_amount * 42 * 0.05)

summary_42 <- sales_data %>%
  group_by(flag_42) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_42)
  )

print(paste('Summary Block 42'))
print(summary_42)

# ---- Transformation Block 43 ----
sales_data <- sales_data %>%
  mutate(flag_43 = ifelse(id %% 44 == 0, 1, 0)) %>%
  mutate(adj_sales_43 = sales_amount * 43 * 0.05)

summary_43 <- sales_data %>%
  group_by(flag_43) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_43)
  )

print(paste('Summary Block 43'))
print(summary_43)

# ---- Transformation Block 44 ----
sales_data <- sales_data %>%
  mutate(flag_44 = ifelse(id %% 45 == 0, 1, 0)) %>%
  mutate(adj_sales_44 = sales_amount * 44 * 0.05)

summary_44 <- sales_data %>%
  group_by(flag_44) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_44)
  )

print(paste('Summary Block 44'))
print(summary_44)

# ---- Transformation Block 45 ----
sales_data <- sales_data %>%
  mutate(flag_45 = ifelse(id %% 46 == 0, 1, 0)) %>%
  mutate(adj_sales_45 = sales_amount * 45 * 0.05)

summary_45 <- sales_data %>%
  group_by(flag_45) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_45)
  )

print(paste('Summary Block 45'))
print(summary_45)

# ---- Transformation Block 46 ----
sales_data <- sales_data %>%
  mutate(flag_46 = ifelse(id %% 47 == 0, 1, 0)) %>%
  mutate(adj_sales_46 = sales_amount * 46 * 0.05)

summary_46 <- sales_data %>%
  group_by(flag_46) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_46)
  )

print(paste('Summary Block 46'))
print(summary_46)

# ---- Transformation Block 47 ----
sales_data <- sales_data %>%
  mutate(flag_47 = ifelse(id %% 48 == 0, 1, 0)) %>%
  mutate(adj_sales_47 = sales_amount * 47 * 0.05)

summary_47 <- sales_data %>%
  group_by(flag_47) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_47)
  )

print(paste('Summary Block 47'))
print(summary_47)

# ---- Transformation Block 48 ----
sales_data <- sales_data %>%
  mutate(flag_48 = ifelse(id %% 49 == 0, 1, 0)) %>%
  mutate(adj_sales_48 = sales_amount * 48 * 0.05)

summary_48 <- sales_data %>%
  group_by(flag_48) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_48)
  )

print(paste('Summary Block 48'))
print(summary_48)

# ---- Transformation Block 49 ----
sales_data <- sales_data %>%
  mutate(flag_49 = ifelse(id %% 50 == 0, 1, 0)) %>%
  mutate(adj_sales_49 = sales_amount * 49 * 0.05)

summary_49 <- sales_data %>%
  group_by(flag_49) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_49)
  )

print(paste('Summary Block 49'))
print(summary_49)

# ---- Transformation Block 50 ----
sales_data <- sales_data %>%
  mutate(flag_50 = ifelse(id %% 51 == 0, 1, 0)) %>%
  mutate(adj_sales_50 = sales_amount * 50 * 0.05)

summary_50 <- sales_data %>%
  group_by(flag_50) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_50)
  )

print(paste('Summary Block 50'))
print(summary_50)

# ---- Transformation Block 51 ----
sales_data <- sales_data %>%
  mutate(flag_51 = ifelse(id %% 52 == 0, 1, 0)) %>%
  mutate(adj_sales_51 = sales_amount * 51 * 0.05)

summary_51 <- sales_data %>%
  group_by(flag_51) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_51)
  )

print(paste('Summary Block 51'))
print(summary_51)

# ---- Transformation Block 52 ----
sales_data <- sales_data %>%
  mutate(flag_52 = ifelse(id %% 53 == 0, 1, 0)) %>%
  mutate(adj_sales_52 = sales_amount * 52 * 0.05)

summary_52 <- sales_data %>%
  group_by(flag_52) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_52)
  )

print(paste('Summary Block 52'))
print(summary_52)

# ---- Transformation Block 53 ----
sales_data <- sales_data %>%
  mutate(flag_53 = ifelse(id %% 54 == 0, 1, 0)) %>%
  mutate(adj_sales_53 = sales_amount * 53 * 0.05)

summary_53 <- sales_data %>%
  group_by(flag_53) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_53)
  )

print(paste('Summary Block 53'))
print(summary_53)

# ---- Transformation Block 54 ----
sales_data <- sales_data %>%
  mutate(flag_54 = ifelse(id %% 55 == 0, 1, 0)) %>%
  mutate(adj_sales_54 = sales_amount * 54 * 0.05)

summary_54 <- sales_data %>%
  group_by(flag_54) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_54)
  )

print(paste('Summary Block 54'))
print(summary_54)

# ---- Transformation Block 55 ----
sales_data <- sales_data %>%
  mutate(flag_55 = ifelse(id %% 56 == 0, 1, 0)) %>%
  mutate(adj_sales_55 = sales_amount * 55 * 0.05)

summary_55 <- sales_data %>%
  group_by(flag_55) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_55)
  )

print(paste('Summary Block 55'))
print(summary_55)

# ---- Transformation Block 56 ----
sales_data <- sales_data %>%
  mutate(flag_56 = ifelse(id %% 57 == 0, 1, 0)) %>%
  mutate(adj_sales_56 = sales_amount * 56 * 0.05)

summary_56 <- sales_data %>%
  group_by(flag_56) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_56)
  )

print(paste('Summary Block 56'))
print(summary_56)

# ---- Transformation Block 57 ----
sales_data <- sales_data %>%
  mutate(flag_57 = ifelse(id %% 58 == 0, 1, 0)) %>%
  mutate(adj_sales_57 = sales_amount * 57 * 0.05)

summary_57 <- sales_data %>%
  group_by(flag_57) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_57)
  )

print(paste('Summary Block 57'))
print(summary_57)

# ---- Transformation Block 58 ----
sales_data <- sales_data %>%
  mutate(flag_58 = ifelse(id %% 59 == 0, 1, 0)) %>%
  mutate(adj_sales_58 = sales_amount * 58 * 0.05)

summary_58 <- sales_data %>%
  group_by(flag_58) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_58)
  )

print(paste('Summary Block 58'))
print(summary_58)

# ---- Transformation Block 59 ----
sales_data <- sales_data %>%
  mutate(flag_59 = ifelse(id %% 60 == 0, 1, 0)) %>%
  mutate(adj_sales_59 = sales_amount * 59 * 0.05)

summary_59 <- sales_data %>%
  group_by(flag_59) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_59)
  )

print(paste('Summary Block 59'))
print(summary_59)

# ---- Transformation Block 60 ----
sales_data <- sales_data %>%
  mutate(flag_60 = ifelse(id %% 61 == 0, 1, 0)) %>%
  mutate(adj_sales_60 = sales_amount * 60 * 0.05)

summary_60 <- sales_data %>%
  group_by(flag_60) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_60)
  )

print(paste('Summary Block 60'))
print(summary_60)

# ---- Transformation Block 61 ----
sales_data <- sales_data %>%
  mutate(flag_61 = ifelse(id %% 62 == 0, 1, 0)) %>%
  mutate(adj_sales_61 = sales_amount * 61 * 0.05)

summary_61 <- sales_data %>%
  group_by(flag_61) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_61)
  )

print(paste('Summary Block 61'))
print(summary_61)

# ---- Transformation Block 62 ----
sales_data <- sales_data %>%
  mutate(flag_62 = ifelse(id %% 63 == 0, 1, 0)) %>%
  mutate(adj_sales_62 = sales_amount * 62 * 0.05)

summary_62 <- sales_data %>%
  group_by(flag_62) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_62)
  )

print(paste('Summary Block 62'))
print(summary_62)

# ---- Transformation Block 63 ----
sales_data <- sales_data %>%
  mutate(flag_63 = ifelse(id %% 64 == 0, 1, 0)) %>%
  mutate(adj_sales_63 = sales_amount * 63 * 0.05)

summary_63 <- sales_data %>%
  group_by(flag_63) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_63)
  )

print(paste('Summary Block 63'))
print(summary_63)

# ---- Transformation Block 64 ----
sales_data <- sales_data %>%
  mutate(flag_64 = ifelse(id %% 65 == 0, 1, 0)) %>%
  mutate(adj_sales_64 = sales_amount * 64 * 0.05)

summary_64 <- sales_data %>%
  group_by(flag_64) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_64)
  )

print(paste('Summary Block 64'))
print(summary_64)

# ---- Transformation Block 65 ----
sales_data <- sales_data %>%
  mutate(flag_65 = ifelse(id %% 66 == 0, 1, 0)) %>%
  mutate(adj_sales_65 = sales_amount * 65 * 0.05)

summary_65 <- sales_data %>%
  group_by(flag_65) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_65)
  )

print(paste('Summary Block 65'))
print(summary_65)

# ---- Transformation Block 66 ----
sales_data <- sales_data %>%
  mutate(flag_66 = ifelse(id %% 67 == 0, 1, 0)) %>%
  mutate(adj_sales_66 = sales_amount * 66 * 0.05)

summary_66 <- sales_data %>%
  group_by(flag_66) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_66)
  )

print(paste('Summary Block 66'))
print(summary_66)

# ---- Transformation Block 67 ----
sales_data <- sales_data %>%
  mutate(flag_67 = ifelse(id %% 68 == 0, 1, 0)) %>%
  mutate(adj_sales_67 = sales_amount * 67 * 0.05)

summary_67 <- sales_data %>%
  group_by(flag_67) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_67)
  )

print(paste('Summary Block 67'))
print(summary_67)

# ---- Transformation Block 68 ----
sales_data <- sales_data %>%
  mutate(flag_68 = ifelse(id %% 69 == 0, 1, 0)) %>%
  mutate(adj_sales_68 = sales_amount * 68 * 0.05)

summary_68 <- sales_data %>%
  group_by(flag_68) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_68)
  )

print(paste('Summary Block 68'))
print(summary_68)

# ---- Transformation Block 69 ----
sales_data <- sales_data %>%
  mutate(flag_69 = ifelse(id %% 70 == 0, 1, 0)) %>%
  mutate(adj_sales_69 = sales_amount * 69 * 0.05)

summary_69 <- sales_data %>%
  group_by(flag_69) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_69)
  )

print(paste('Summary Block 69'))
print(summary_69)

# ---- Transformation Block 70 ----
sales_data <- sales_data %>%
  mutate(flag_70 = ifelse(id %% 71 == 0, 1, 0)) %>%
  mutate(adj_sales_70 = sales_amount * 70 * 0.05)

summary_70 <- sales_data %>%
  group_by(flag_70) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_70)
  )

print(paste('Summary Block 70'))
print(summary_70)

# ---- Transformation Block 71 ----
sales_data <- sales_data %>%
  mutate(flag_71 = ifelse(id %% 72 == 0, 1, 0)) %>%
  mutate(adj_sales_71 = sales_amount * 71 * 0.05)

summary_71 <- sales_data %>%
  group_by(flag_71) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_71)
  )

print(paste('Summary Block 71'))
print(summary_71)

# ---- Transformation Block 72 ----
sales_data <- sales_data %>%
  mutate(flag_72 = ifelse(id %% 73 == 0, 1, 0)) %>%
  mutate(adj_sales_72 = sales_amount * 72 * 0.05)

summary_72 <- sales_data %>%
  group_by(flag_72) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_72)
  )

print(paste('Summary Block 72'))
print(summary_72)

# ---- Transformation Block 73 ----
sales_data <- sales_data %>%
  mutate(flag_73 = ifelse(id %% 74 == 0, 1, 0)) %>%
  mutate(adj_sales_73 = sales_amount * 73 * 0.05)

summary_73 <- sales_data %>%
  group_by(flag_73) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_73)
  )

print(paste('Summary Block 73'))
print(summary_73)

# ---- Transformation Block 74 ----
sales_data <- sales_data %>%
  mutate(flag_74 = ifelse(id %% 75 == 0, 1, 0)) %>%
  mutate(adj_sales_74 = sales_amount * 74 * 0.05)

summary_74 <- sales_data %>%
  group_by(flag_74) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_74)
  )

print(paste('Summary Block 74'))
print(summary_74)

# ---- Transformation Block 75 ----
sales_data <- sales_data %>%
  mutate(flag_75 = ifelse(id %% 76 == 0, 1, 0)) %>%
  mutate(adj_sales_75 = sales_amount * 75 * 0.05)

summary_75 <- sales_data %>%
  group_by(flag_75) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_75)
  )

print(paste('Summary Block 75'))
print(summary_75)

# ---- Transformation Block 76 ----
sales_data <- sales_data %>%
  mutate(flag_76 = ifelse(id %% 77 == 0, 1, 0)) %>%
  mutate(adj_sales_76 = sales_amount * 76 * 0.05)

summary_76 <- sales_data %>%
  group_by(flag_76) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_76)
  )

print(paste('Summary Block 76'))
print(summary_76)

# ---- Transformation Block 77 ----
sales_data <- sales_data %>%
  mutate(flag_77 = ifelse(id %% 78 == 0, 1, 0)) %>%
  mutate(adj_sales_77 = sales_amount * 77 * 0.05)

summary_77 <- sales_data %>%
  group_by(flag_77) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_77)
  )

print(paste('Summary Block 77'))
print(summary_77)

# ---- Transformation Block 78 ----
sales_data <- sales_data %>%
  mutate(flag_78 = ifelse(id %% 79 == 0, 1, 0)) %>%
  mutate(adj_sales_78 = sales_amount * 78 * 0.05)

summary_78 <- sales_data %>%
  group_by(flag_78) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_78)
  )

print(paste('Summary Block 78'))
print(summary_78)

# ---- Transformation Block 79 ----
sales_data <- sales_data %>%
  mutate(flag_79 = ifelse(id %% 80 == 0, 1, 0)) %>%
  mutate(adj_sales_79 = sales_amount * 79 * 0.05)

summary_79 <- sales_data %>%
  group_by(flag_79) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_79)
  )

print(paste('Summary Block 79'))
print(summary_79)

# ---- Transformation Block 80 ----
sales_data <- sales_data %>%
  mutate(flag_80 = ifelse(id %% 81 == 0, 1, 0)) %>%
  mutate(adj_sales_80 = sales_amount * 80 * 0.05)

summary_80 <- sales_data %>%
  group_by(flag_80) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_80)
  )

print(paste('Summary Block 80'))
print(summary_80)

# ---- Transformation Block 81 ----
sales_data <- sales_data %>%
  mutate(flag_81 = ifelse(id %% 82 == 0, 1, 0)) %>%
  mutate(adj_sales_81 = sales_amount * 81 * 0.05)

summary_81 <- sales_data %>%
  group_by(flag_81) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_81)
  )

print(paste('Summary Block 81'))
print(summary_81)

# ---- Transformation Block 82 ----
sales_data <- sales_data %>%
  mutate(flag_82 = ifelse(id %% 83 == 0, 1, 0)) %>%
  mutate(adj_sales_82 = sales_amount * 82 * 0.05)

summary_82 <- sales_data %>%
  group_by(flag_82) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_82)
  )

print(paste('Summary Block 82'))
print(summary_82)

# ---- Transformation Block 83 ----
sales_data <- sales_data %>%
  mutate(flag_83 = ifelse(id %% 84 == 0, 1, 0)) %>%
  mutate(adj_sales_83 = sales_amount * 83 * 0.05)

summary_83 <- sales_data %>%
  group_by(flag_83) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_83)
  )

print(paste('Summary Block 83'))
print(summary_83)

# ---- Transformation Block 84 ----
sales_data <- sales_data %>%
  mutate(flag_84 = ifelse(id %% 85 == 0, 1, 0)) %>%
  mutate(adj_sales_84 = sales_amount * 84 * 0.05)

summary_84 <- sales_data %>%
  group_by(flag_84) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_84)
  )

print(paste('Summary Block 84'))
print(summary_84)

# ---- Transformation Block 85 ----
sales_data <- sales_data %>%
  mutate(flag_85 = ifelse(id %% 86 == 0, 1, 0)) %>%
  mutate(adj_sales_85 = sales_amount * 85 * 0.05)

summary_85 <- sales_data %>%
  group_by(flag_85) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_85)
  )

print(paste('Summary Block 85'))
print(summary_85)

# ---- Transformation Block 86 ----
sales_data <- sales_data %>%
  mutate(flag_86 = ifelse(id %% 87 == 0, 1, 0)) %>%
  mutate(adj_sales_86 = sales_amount * 86 * 0.05)

summary_86 <- sales_data %>%
  group_by(flag_86) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_86)
  )

print(paste('Summary Block 86'))
print(summary_86)

# ---- Transformation Block 87 ----
sales_data <- sales_data %>%
  mutate(flag_87 = ifelse(id %% 88 == 0, 1, 0)) %>%
  mutate(adj_sales_87 = sales_amount * 87 * 0.05)

summary_87 <- sales_data %>%
  group_by(flag_87) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_87)
  )

print(paste('Summary Block 87'))
print(summary_87)

# ---- Transformation Block 88 ----
sales_data <- sales_data %>%
  mutate(flag_88 = ifelse(id %% 89 == 0, 1, 0)) %>%
  mutate(adj_sales_88 = sales_amount * 88 * 0.05)

summary_88 <- sales_data %>%
  group_by(flag_88) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_88)
  )

print(paste('Summary Block 88'))
print(summary_88)

# ---- Transformation Block 89 ----
sales_data <- sales_data %>%
  mutate(flag_89 = ifelse(id %% 90 == 0, 1, 0)) %>%
  mutate(adj_sales_89 = sales_amount * 89 * 0.05)

summary_89 <- sales_data %>%
  group_by(flag_89) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_89)
  )

print(paste('Summary Block 89'))
print(summary_89)

# ---- Transformation Block 90 ----
sales_data <- sales_data %>%
  mutate(flag_90 = ifelse(id %% 91 == 0, 1, 0)) %>%
  mutate(adj_sales_90 = sales_amount * 90 * 0.05)

summary_90 <- sales_data %>%
  group_by(flag_90) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_90)
  )

print(paste('Summary Block 90'))
print(summary_90)

# ---- Transformation Block 91 ----
sales_data <- sales_data %>%
  mutate(flag_91 = ifelse(id %% 92 == 0, 1, 0)) %>%
  mutate(adj_sales_91 = sales_amount * 91 * 0.05)

summary_91 <- sales_data %>%
  group_by(flag_91) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_91)
  )

print(paste('Summary Block 91'))
print(summary_91)

# ---- Transformation Block 92 ----
sales_data <- sales_data %>%
  mutate(flag_92 = ifelse(id %% 93 == 0, 1, 0)) %>%
  mutate(adj_sales_92 = sales_amount * 92 * 0.05)

summary_92 <- sales_data %>%
  group_by(flag_92) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_92)
  )

print(paste('Summary Block 92'))
print(summary_92)

# ---- Transformation Block 93 ----
sales_data <- sales_data %>%
  mutate(flag_93 = ifelse(id %% 94 == 0, 1, 0)) %>%
  mutate(adj_sales_93 = sales_amount * 93 * 0.05)

summary_93 <- sales_data %>%
  group_by(flag_93) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_93)
  )

print(paste('Summary Block 93'))
print(summary_93)

# ---- Transformation Block 94 ----
sales_data <- sales_data %>%
  mutate(flag_94 = ifelse(id %% 95 == 0, 1, 0)) %>%
  mutate(adj_sales_94 = sales_amount * 94 * 0.05)

summary_94 <- sales_data %>%
  group_by(flag_94) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_94)
  )

print(paste('Summary Block 94'))
print(summary_94)

# ---- Transformation Block 95 ----
sales_data <- sales_data %>%
  mutate(flag_95 = ifelse(id %% 96 == 0, 1, 0)) %>%
  mutate(adj_sales_95 = sales_amount * 95 * 0.05)

summary_95 <- sales_data %>%
  group_by(flag_95) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_95)
  )

print(paste('Summary Block 95'))
print(summary_95)

# ---- Transformation Block 96 ----
sales_data <- sales_data %>%
  mutate(flag_96 = ifelse(id %% 97 == 0, 1, 0)) %>%
  mutate(adj_sales_96 = sales_amount * 96 * 0.05)

summary_96 <- sales_data %>%
  group_by(flag_96) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_96)
  )

print(paste('Summary Block 96'))
print(summary_96)

# ---- Transformation Block 97 ----
sales_data <- sales_data %>%
  mutate(flag_97 = ifelse(id %% 98 == 0, 1, 0)) %>%
  mutate(adj_sales_97 = sales_amount * 97 * 0.05)

summary_97 <- sales_data %>%
  group_by(flag_97) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_97)
  )

print(paste('Summary Block 97'))
print(summary_97)

# ---- Transformation Block 98 ----
sales_data <- sales_data %>%
  mutate(flag_98 = ifelse(id %% 99 == 0, 1, 0)) %>%
  mutate(adj_sales_98 = sales_amount * 98 * 0.05)

summary_98 <- sales_data %>%
  group_by(flag_98) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_98)
  )

print(paste('Summary Block 98'))
print(summary_98)

# ---- Transformation Block 99 ----
sales_data <- sales_data %>%
  mutate(flag_99 = ifelse(id %% 100 == 0, 1, 0)) %>%
  mutate(adj_sales_99 = sales_amount * 99 * 0.05)

summary_99 <- sales_data %>%
  group_by(flag_99) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_99)
  )

print(paste('Summary Block 99'))
print(summary_99)

# ---- Transformation Block 100 ----
sales_data <- sales_data %>%
  mutate(flag_100 = ifelse(id %% 101 == 0, 1, 0)) %>%
  mutate(adj_sales_100 = sales_amount * 100 * 0.05)

summary_100 <- sales_data %>%
  group_by(flag_100) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_100)
  )

print(paste('Summary Block 100'))
print(summary_100)

# ---- Transformation Block 101 ----
sales_data <- sales_data %>%
  mutate(flag_101 = ifelse(id %% 102 == 0, 1, 0)) %>%
  mutate(adj_sales_101 = sales_amount * 101 * 0.05)

summary_101 <- sales_data %>%
  group_by(flag_101) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_101)
  )

print(paste('Summary Block 101'))
print(summary_101)

# ---- Transformation Block 102 ----
sales_data <- sales_data %>%
  mutate(flag_102 = ifelse(id %% 103 == 0, 1, 0)) %>%
  mutate(adj_sales_102 = sales_amount * 102 * 0.05)

summary_102 <- sales_data %>%
  group_by(flag_102) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_102)
  )

print(paste('Summary Block 102'))
print(summary_102)

# ---- Transformation Block 103 ----
sales_data <- sales_data %>%
  mutate(flag_103 = ifelse(id %% 104 == 0, 1, 0)) %>%
  mutate(adj_sales_103 = sales_amount * 103 * 0.05)

summary_103 <- sales_data %>%
  group_by(flag_103) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_103)
  )

print(paste('Summary Block 103'))
print(summary_103)

# ---- Transformation Block 104 ----
sales_data <- sales_data %>%
  mutate(flag_104 = ifelse(id %% 105 == 0, 1, 0)) %>%
  mutate(adj_sales_104 = sales_amount * 104 * 0.05)

summary_104 <- sales_data %>%
  group_by(flag_104) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_104)
  )

print(paste('Summary Block 104'))
print(summary_104)

# ---- Transformation Block 105 ----
sales_data <- sales_data %>%
  mutate(flag_105 = ifelse(id %% 106 == 0, 1, 0)) %>%
  mutate(adj_sales_105 = sales_amount * 105 * 0.05)

summary_105 <- sales_data %>%
  group_by(flag_105) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_105)
  )

print(paste('Summary Block 105'))
print(summary_105)

# ---- Transformation Block 106 ----
sales_data <- sales_data %>%
  mutate(flag_106 = ifelse(id %% 107 == 0, 1, 0)) %>%
  mutate(adj_sales_106 = sales_amount * 106 * 0.05)

summary_106 <- sales_data %>%
  group_by(flag_106) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_106)
  )

print(paste('Summary Block 106'))
print(summary_106)

# ---- Transformation Block 107 ----
sales_data <- sales_data %>%
  mutate(flag_107 = ifelse(id %% 108 == 0, 1, 0)) %>%
  mutate(adj_sales_107 = sales_amount * 107 * 0.05)

summary_107 <- sales_data %>%
  group_by(flag_107) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_107)
  )

print(paste('Summary Block 107'))
print(summary_107)

# ---- Transformation Block 108 ----
sales_data <- sales_data %>%
  mutate(flag_108 = ifelse(id %% 109 == 0, 1, 0)) %>%
  mutate(adj_sales_108 = sales_amount * 108 * 0.05)

summary_108 <- sales_data %>%
  group_by(flag_108) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_108)
  )

print(paste('Summary Block 108'))
print(summary_108)

# ---- Transformation Block 109 ----
sales_data <- sales_data %>%
  mutate(flag_109 = ifelse(id %% 110 == 0, 1, 0)) %>%
  mutate(adj_sales_109 = sales_amount * 109 * 0.05)

summary_109 <- sales_data %>%
  group_by(flag_109) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_109)
  )

print(paste('Summary Block 109'))
print(summary_109)

# ---- Transformation Block 110 ----
sales_data <- sales_data %>%
  mutate(flag_110 = ifelse(id %% 111 == 0, 1, 0)) %>%
  mutate(adj_sales_110 = sales_amount * 110 * 0.05)

summary_110 <- sales_data %>%
  group_by(flag_110) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_110)
  )

print(paste('Summary Block 110'))
print(summary_110)

# ---- Transformation Block 111 ----
sales_data <- sales_data %>%
  mutate(flag_111 = ifelse(id %% 112 == 0, 1, 0)) %>%
  mutate(adj_sales_111 = sales_amount * 111 * 0.05)

summary_111 <- sales_data %>%
  group_by(flag_111) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_111)
  )

print(paste('Summary Block 111'))
print(summary_111)

# ---- Transformation Block 112 ----
sales_data <- sales_data %>%
  mutate(flag_112 = ifelse(id %% 113 == 0, 1, 0)) %>%
  mutate(adj_sales_112 = sales_amount * 112 * 0.05)

summary_112 <- sales_data %>%
  group_by(flag_112) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_112)
  )

print(paste('Summary Block 112'))
print(summary_112)

# ---- Transformation Block 113 ----
sales_data <- sales_data %>%
  mutate(flag_113 = ifelse(id %% 114 == 0, 1, 0)) %>%
  mutate(adj_sales_113 = sales_amount * 113 * 0.05)

summary_113 <- sales_data %>%
  group_by(flag_113) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_113)
  )

print(paste('Summary Block 113'))
print(summary_113)

# ---- Transformation Block 114 ----
sales_data <- sales_data %>%
  mutate(flag_114 = ifelse(id %% 115 == 0, 1, 0)) %>%
  mutate(adj_sales_114 = sales_amount * 114 * 0.05)

summary_114 <- sales_data %>%
  group_by(flag_114) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_114)
  )

print(paste('Summary Block 114'))
print(summary_114)

# ---- Transformation Block 115 ----
sales_data <- sales_data %>%
  mutate(flag_115 = ifelse(id %% 116 == 0, 1, 0)) %>%
  mutate(adj_sales_115 = sales_amount * 115 * 0.05)

summary_115 <- sales_data %>%
  group_by(flag_115) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_115)
  )

print(paste('Summary Block 115'))
print(summary_115)

# ---- Transformation Block 116 ----
sales_data <- sales_data %>%
  mutate(flag_116 = ifelse(id %% 117 == 0, 1, 0)) %>%
  mutate(adj_sales_116 = sales_amount * 116 * 0.05)

summary_116 <- sales_data %>%
  group_by(flag_116) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_116)
  )

print(paste('Summary Block 116'))
print(summary_116)

# ---- Transformation Block 117 ----
sales_data <- sales_data %>%
  mutate(flag_117 = ifelse(id %% 118 == 0, 1, 0)) %>%
  mutate(adj_sales_117 = sales_amount * 117 * 0.05)

summary_117 <- sales_data %>%
  group_by(flag_117) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_117)
  )

print(paste('Summary Block 117'))
print(summary_117)

# ---- Transformation Block 118 ----
sales_data <- sales_data %>%
  mutate(flag_118 = ifelse(id %% 119 == 0, 1, 0)) %>%
  mutate(adj_sales_118 = sales_amount * 118 * 0.05)

summary_118 <- sales_data %>%
  group_by(flag_118) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_118)
  )

print(paste('Summary Block 118'))
print(summary_118)

# ---- Transformation Block 119 ----
sales_data <- sales_data %>%
  mutate(flag_119 = ifelse(id %% 120 == 0, 1, 0)) %>%
  mutate(adj_sales_119 = sales_amount * 119 * 0.05)

summary_119 <- sales_data %>%
  group_by(flag_119) %>%
  summarise(
    count = n(),
    avg_sales = mean(adj_sales_119)
  )

print(paste('Summary Block 119'))
print(summary_119)