# proxy
unfa's Proxy Manager

## What is this?

This is a Bash script meant as a tool to encode and manage proxy footage to speed up video editng. It uses ffmpeg and symlinks to achieve this goal.

## Workflow

1. Make a copy of your footage before you let this script work on it. I take no responsibility for any damage you might create by using it carelessly. It should not cause any data loss, but I won't guarantee anything.
1. Download the script and place in in a folder where your fotage resides.
1. Run it with the `encode` command:

       ./proxy.sh encode
   
Warning: this step is a buit buggy and likes to terminate early - that may work differently for your footage. Nothing is lost, but I had to run this script in loop until it transcoded all the footage. It will automatically skip encoding any proxy footage that has already been sucessfully transcoded. if an encode failed previously re-runing the command will start over that file.
Once the command finished your original footagewill be replaced wiht symlinks pointing to newly created proxy files - don't worry - the original footage is still there, only renamed to organize things. Now create your video editing project and import your footage using the created symlinks.

1. Once you've done your editing, save and close the video editor's project to make sure it'll load the full qualit yfootage once we re-link it.
1. Now run the scriot again wiht the `original` command:

       ./proxy.sh original
     
This will replace the symlinks and mkae them point to your original high-qulity footage.

1. Load your video editing project and render out the video.

1. If you want to go back to editing, run the script again with `proxy` command to re-link the proxy footage again, without transcoding it needlessly:

       ./proxy.sh proxy


There's a planned `cleanup` command that'll remoce al link and move the original footage to it's place to restore the initial state of things - that'd be good to do when archiving the project. I haven't implement this yet.

## Limitations

The progam only recognized MKV and MP4 fiels so far, becasue that's what I needed to digest. It requires ffmpeg to be installed in the system to handle vidoe transcoding. The encoding options will preserve original resolutions, as that is likely to break video editing projects if not handled by the editor itself, it also retains all audio tracks and convert them to 16-bit PCM for fast seeking.

## Compatibility

I've created this tool when I had to edit a video project in Olive 0.12 that had over 5 hours of 15 MBps 4:4:4 3840x1080p 60 FPS footage as well as 4:2:0 30 FPS 4K footage of even higher bitrate having both composited together. On my hardware Olive would not be able to play that smoothly, and the RAM usage would quickly kill my PC (despite having 32 GB of memory installed).
