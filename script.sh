# Preliminary instructions to resolve permission issues related to Xauthority data.
# If you encounter issues, you can delete the existing Xauthority file and retry.
# In extreme cases, you might need to run the script as the root user.
# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# It still not working, try running the script as root.

# Declare the XAUTH variable to hold the path for Xauthority data.
XAUTH=/tmp/.docker.xauth

# Notify the user that Xauthority data preparation is starting.
echo "Preparing Xauthority data..."

# Fetch the last Xauthority record for display :0 and manipulate it for later merging.
# The 'sed' command replaces the first 4 bytes to make it suitable for nmerge.
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')

# Check if XAUTH file already exists.
if [ ! -f $XAUTH ]; then
    # If XAUTH file doesn't exist, check if xauth_list is empty or not.
    if [ ! -z "$xauth_list" ]; then
        # Merge the Xauthority record into the XAUTH file.
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        # Create an empty XAUTH file if no existing record is found.
        touch $XAUTH
    fi
    # Update permissions to make it readable for all users.
    chmod a+r $XAUTH
fi

# Notify the user that Xauthority data preparation is done.
echo "Done."

# Diagnostic Information.
echo ""
echo "Verifying file contents:"
# Verify if the XAUTH file contains valid X11 authority data.
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""

echo "Permissions:"
# Display the file permissions of the XAUTH file.
ls -FAlh $XAUTH
echo ""

# Notify the user that Docker is about to run.
echo "Running docker..."

# Execute Docker with specified settings to enable GUI functionality and set other configurations.
# Flags and environment variables ensure that the container can interact with X11 server.
# Privileged mode and Nvidia runtime are enabled as well.
docker run -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --net=host \
    --privileged \
    --runtime=nvidia \
    <IMAGE>:<TAG> \
    bash

# Notify the user that Docker has finished running.
echo "Done."