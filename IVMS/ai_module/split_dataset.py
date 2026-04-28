# # import os
# # import shutil

# # # =========================
# # # BASE PATH
# # # =========================
# # base_dir = "datasets"
# # output = f"{base_dir}/final_dataset"

# # # =========================
# # # CREATE OUTPUT STRUCTURE
# # # =========================
# # for folder in ["images/train", "images/val", "labels/train", "labels/val"]:
# #     os.makedirs(f"{output}/{folder}", exist_ok=True)

# # # =========================
# # # COPY FUNCTION
# # # =========================
# # def copy_data(src_img, src_lbl, dst_img, dst_lbl):
# #     if not os.path.exists(src_img):
# #         return

# #     for file in os.listdir(src_img):

# #         if not file.lower().endswith((".jpg", ".jpeg", ".png")):
# #             continue

# #         name = file.rsplit(".", 1)[0]
# #         label = name + ".txt"

# #         src_img_path = os.path.join(src_img, file)
# #         src_lbl_path = os.path.join(src_lbl, label)

# #         dst_img_path = os.path.join(dst_img, file)
# #         dst_lbl_path = os.path.join(dst_lbl, label)

# #         # skip duplicates
# #         if os.path.exists(dst_img_path):
# #             continue

# #         shutil.copy(src_img_path, dst_img_path)

# #         if os.path.exists(src_lbl_path):
# #             shutil.copy(src_lbl_path, dst_lbl_path)
# #         else:
# #             open(dst_lbl_path, "w").close()

# # # =========================
# # # LOOP THROUGH ALL DATASETS
# # # =========================
# # datasets = [
# #     d for d in os.listdir(base_dir)
# #     if os.path.isdir(os.path.join(base_dir, d)) and d != "final_dataset"
# # ]

# # print("📂 Found datasets:", datasets)

# # for ds in datasets:
# #     print(f"🔄 Processing {ds}...")

# #     base = os.path.join(base_dir, ds)

# #     # TRAIN → TRAIN
# #     copy_data(
# #         f"{base}/train/images",
# #         f"{base}/train/labels",
# #         f"{output}/images/train",
# #         f"{output}/labels/train"
# #     )

# #     # VALID → VAL
# #     copy_data(
# #         f"{base}/valid/images",
# #         f"{base}/valid/labels",
# #         f"{output}/images/val",
# #         f"{output}/labels/val"
# #     )

# #     # OPTIONAL: TEST → VAL (if you want)
# #     include_test = False

# #     if include_test:
# #         copy_data(
# #             f"{base}/test/images",
# #             f"{base}/test/labels",
# #             f"{output}/images/val",
# #             f"{output}/labels/val"
# #         )

# # print("🎉 DONE: All datasets merged!")

# import os
# import random
# import shutil

# # =========================
# # PATHS
# # =========================
# base = "datasets/final_dataset"
# output_base = "datasets"

# train_img_path = f"{base}/images/train"
# train_lbl_path = f"{base}/labels/train"

# val_img_path = f"{base}/images/val"
# val_lbl_path = f"{base}/labels/val"

# # =========================
# # LOAD TRAIN IMAGES
# # =========================
# images = [
#     f for f in os.listdir(train_img_path)
#     if f.lower().endswith((".jpg", ".jpeg", ".png"))
# ]

# random.shuffle(images)

# total = len(images)
# print(f"📸 Total train images: {total}")

# # =========================
# # SPLITS (%)
# # =========================
# splits = {
#     "exp_60": int(0.6 * total),
#     "exp_70": int(0.7 * total),
#     "exp_80": int(0.8 * total),
# }

# # =========================
# # CREATE SPLITS
# # =========================
# for exp, count in splits.items():
#     print(f"📦 Creating {exp} with {count} images")

#     # create folders
#     for folder in ["images/train", "images/val", "labels/train", "labels/val"]:
#         os.makedirs(f"{output_base}/{exp}/{folder}", exist_ok=True)

#     selected = images[:count]

#     # TRAIN
#     for img in selected:
#         label = img.rsplit(".", 1)[0] + ".txt"

#         shutil.copy(
#             f"{train_img_path}/{img}",
#             f"{output_base}/{exp}/images/train/{img}"
#         )

#         shutil.copy(
#             f"{train_lbl_path}/{label}",
#             f"{output_base}/{exp}/labels/train/{label}"
#         )

#     # VAL (same for all experiments)
#     for img in os.listdir(val_img_path):
#         if not img.lower().endswith((".jpg", ".jpeg", ".png")):
#             continue

#         label = img.rsplit(".", 1)[0] + ".txt"

#         shutil.copy(
#             f"{val_img_path}/{img}",
#             f"{output_base}/{exp}/images/val/{img}"
#         )

#         shutil.copy(
#             f"{val_lbl_path}/{label}",
#             f"{output_base}/{exp}/labels/val/{label}"
#         )

# print("🎉 DONE: exp_60, exp_70, exp_80 created")

import os

base_dir = "datasets"

# 🔧 UPDATE THIS (your classes)
nc = 3
names = ["car", "person", "bike"]

# find all exp folders
exp_folders = [
    d for d in os.listdir(base_dir)
    if d.startswith("exp_") and os.path.isdir(os.path.join(base_dir, d))
]

print("Found experiments:", exp_folders)

for exp in exp_folders:
    yaml_path = os.path.join(base_dir, exp, "data.yaml")

    content = f"""train: datasets/{exp}/images/train
val: datasets/{exp}/images/val

nc: {nc}
names: {names}
"""

    with open(yaml_path, "w") as f:
        f.write(content)

    print(f"✅ Created: {yaml_path}")

print("🎉 All data.yaml files created!")