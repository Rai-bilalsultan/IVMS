from ultralytics import YOLO
import os

def train_all_experiments():

    # EXPERIMENT LIST
    exps = ["exp_60", "exp_70", "exp_80"]

    for exp in exps:
        model = YOLO("yolo11n.pt")
        print(f"\n🚀 Training on {exp}...\n")

        data_yaml = f"datasets/{exp}/data.yaml"

        if not os.path.exists(data_yaml):
            with open(data_yaml, "w") as f:
                f.write("""train: images/trainval: images/valnc: 3names: ["car", "person", "bike"]""")

        # TRAIN MODEL
        model.train(
            data=data_yaml,
            epochs=50,
            patience=10,
            augment=True,
            imgsz=640,
            batch=4,
            workers=2,
            device="cpu",
            cache=True,
            project="runs/vehicle",
            name=exp,
            exist_ok=True
        )

    print("\n🎉 All experiments completed!")

if __name__ == "__main__":
    train_all_experiments()