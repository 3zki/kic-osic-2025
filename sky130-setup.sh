#!/bin/sh
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for KIC Yagami
# This script is for use with SKY130.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="/usr/local/pdk"
export MY_STDCELL=sky130_fd_sc_hd
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export PDK=sky130A

# --------
echo ""
echo ">>>> Initializing..."
echo ""

# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	mkdir $HOME/.klayout
	cp -f sky130/klayoutrc $HOME/.klayout
	cp -rf sky130/macros $HOME/.klayout/macros
	# cp -rf sky130/drc $HOME/.klayout/drc
	cp -rf sky130/lvs $HOME/.klayout/lvs
	# cp -rf sky130/pymacros $HOME/.klayout/pymacros
	mkdir $HOME/.klayout/libraries
fi

# Install GDSfactory and PDK
# -----------------------------------

#Patch: klayout==0.29.12 went wrong
python3.12 -m pip install klayout==0.29.10
python3.12 -m pip install sky130==0.12.2 flayout
#Patch klayout==0.29.10 is missing 'attrs'
python3.12 -m pip install attrs

# Create .spiceinit
# -----------------
{
	echo "set num_threads=4"
	echo "set ngbehavior=hsa"
	echo "set ng_nomodcheck"
} > "$HOME/.spiceinit"

# Create iic-init.sh
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
{
	echo "export PDK_ROOT=$PDK_ROOT"
	echo "export PDK=$PDK"
	echo "export STD_CELL_LIBRARY=$MY_STDCELL"
} >> "$HOME/.bashrc"

# Copy various things
# -------------------
export PDK_ROOT=$PDK_ROOT
export PDK=$PDK
export STD_CELL_LIBRARY=$MY_STDCELL
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem
cp -f $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc $HOME/.magicrc
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/drc $HOME/.klayout/drc
# cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/lvs $HOME/.klayout/lvs
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/pymacros $HOME/.klayout/pymacros
mkdir $HOME/.klayout/tech/
mkdir $HOME/.klayout/tech/sky130
cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/$PDK.lyp $HOME/.klayout/tech/sky130/$PDK.lyp
cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/$PDK.lyt $HOME/.klayout/tech/sky130/$PDK.lyt
cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/$PDK.map $HOME/.klayout/tech/sky130/$PDK.map
#cp -f $PDK_ROOT/$PDK/libs.ref/sky130_fd_pr/gds/sky130_fd_pr.gds $HOME/.klayout/libraries/
#cp -f $PDK_ROOT/$PDK/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds $HOME/.klayout/libraries/
#cp -f $PDK_ROOT/$PDK/libs.ref/sky130_fd_sc_hvl/gds/sky130_fd_sc_hvl.gds $HOME/.klayout/libraries/

# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------
sed -i -e 's/^set SKYWATER_MODELS/# set SKYWATER_MODELS/g' "$HOME/.xschem/xschemrc"
echo 'set SKYWATER_MODELS $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice' >> "$HOME/.xschem/xschemrc"
sed -i -e 's/^set SKYWATER_STDCELLS/# set SKYWATER_STD_CELLS/g' "$HOME/.xschem/xschemrc"
echo 'set SKYWATER_STDCELLS $env(PDK_ROOT)/$env(PDK)/libs.ref/sky130_fd_sc_hd/spice' >> "$HOME/.xschem/xschemrc"


# Finished
# --------
echo ""
echo ">>>> All done. Please restart"
echo ""
