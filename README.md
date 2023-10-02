# gaussian_splat

Super simple 2 container solution to getting gaussian splatting going.

# wait 2 containers?

Why 2 containers?

Colmap wouldn't use the GPU on a container that I installed Colmap on manaully.  Probably solvable, but I couldn't be bothered.

So I use a colmap container someone else put together.  (I assume the developer? maybe not? use at your own risk).

The other image uses a Nvidia provided image that has CUDA 11.6 installed.  This solved my dependency hell trying to compile the code provided by the official repository for gaussian splatting.

See: https://github.com/graphdeco-inria/gaussian-splatting

If you need help? that repo is what does the actual hard part of all this.  If you need help and you are using these scripts, **don't ask them**.  Probably don't ask me either to be honest, but I can give it a shot.  check the issues tab.  Either way; don't bug the original authors unless you are willing to learn how to figure it out yourself without my code.  Those developers don't need to debug my first run shell scripts and containers.  They are busy making Gaussian Splatting better (or graduating or whatever), they don't need my Docker failures clogging their debugging issues!

When building you will need Docker, Docker Compose, the latest Nvidia Drivers and the ability to run CUDA (probably need the container toolkit stuff installed too).  Newer versions of CUDA on the host machine shouldn't matter.  It uses 11.6 in the container.  (My computer runs with CUDA 12.2, so this is fine).

My environment is Ubuntu 22.04 running in WSL2 on Windows.  I installed all the nvidia container stuff on windows, and this more or less works.

# How to actually use.

Install dependencies.

- Docker
- Docker compose
- Nvida *everything*
- Docker Desktop for windows
- WSL 2

Build the containers.

Start WSL2, go to the folder you extracted all this stuff to.

docker compose build

Build will make 2 things
- A splat image
- A colmap image

Put your video you want to use as your source data into the **video_input** folder

run:  **docker compose run colmap**

(You can edit the compose file to change the default number of frames per second of video, you only want ~70-150 frames, and the default frame rate is 0.5)

When that completes, hopefully it worked, you'll end up with your video file renamed to [videofile.mp4].processed (or whatever)  If you want to do it again, at different framerate or something just remove the .processed on the end of the file name.

Then, run: **docker compose run splat**

This processes everything in the splat_input folder, and creates a model in the model_output folder.   The output will be named based on the input folder name and the parameter used to determine how many training epochs.

I've set this to 7000, edit compose.yml to change this.  (7000 works in most examples with ~50-100 images on my 8gb gaphics cards, more iterations uses more ram apparently)

I picked 7000 fairly arbitrarily, based off recommendations of others on the internet.

# Anything else?

The nice thing about the process I've outlined above, it will batch process.  So you can dump 4 videos into the video input folder, and run colmap and it will just do its thing.

Then run splat, and it will just run the 7000 iterations on all the folders waiting to be processed.    Fire and forget.

If you want to add different parameters to the training run, know this.  The iterations parameter needs to be first (I use it to name things), and I define the input folder and model output folder hard-coded in the script.  (see: run_splat.sh),  But I append all other parameters after that.

So, by default you get:

    conda run --no-capture-output --name gaussian_splatting python train.py -s ${infolder} 
                                                                            --model_path ${outfolder} 
                                                                            --iterations ${iterations} 

and the compose.yml command looks like this:

    command: [ "/bin/bash", "--login", "-c", "/workspace/run-splat.sh 7000" ]

If you want to add parameters onto the conda run command, for training.  (like --data_device CPU to run slower, but using less VRAM when you have lots of images)

You'd change the command to this:

    command: [ "/bin/bash", "--login", "-c", "/workspace/run-splat.sh 7000 --data_device CPU" ]

The stuff between the double quotes for the run-splat.sh script is where you put the parameters.  but **the iterations parameter (7000 in the example above) must be first**
