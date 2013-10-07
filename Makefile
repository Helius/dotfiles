CP=cp --no-dereference
RM=rm -rf
MKDIR=mkdir -p
ECHO=@echo -e

SRV_NAME=gitlab.stb.eltex.loc

BUILD=build
WQMAKE=$(CURDIR)/wqmake
INSTALL=install
SRC=src

EXT_LIB_PATH=src/ext/lib
EXT_INC_PATH=src/ext/inc
INST_LIB_PATH=lib

STBSETTINGS_PRO=stbsettings.pro
STBSETTINGS_SRC_PATH=./src/stbsettings
STBSETTINGS_TARGET=libstbsettings.so
STBSETTINGS_INC=stbsettings.h
STBSETTINGS_INST_BUILD_DIR=../ext/lib/
STBSETTINGS_INST_HEADER_DIR=../ext/inc/

STBMAIN_PRO=stbmain.pro
STBMAIN_SRC_PATH=./src/stbmain
STBMAIN_TARGET=stbmain

WEATHER_PRO=weather.pro
WEATHER_SRC_PATH=./src/weather
WEATHER_TARGET=libweather.so
WEATHER_PATH=weather

MEDIAPLAYER_PRO=mediaplayer.pro
MEDIAPLAYER_SRC_PATH=./src/mediaplayer
MEDIAPLAYER_TARGET=libmediaplayer.so
MEDIAPLAYER_PATH=mediaplayer

#IPTVPLAYER_PRO=iptvplayer.pro
#IPTVPLAYER_SRC_PATH=./src/iptvplayer
#IPTVPLAYER_TARGET=libiptvplayer.so
#IPTVPLAYER_PATH=iptvplayer

IPTVPLAYER_PRO=iptv_new.pro
IPTVPLAYER_SRC_PATH=./src/iptv_new
IPTVPLAYER_TARGET=libiptv_new.so
IPTVPLAYER_PATH=iptv_new

SETTINGS_PRO=settings.pro
SETTINGS_SRC_PATH=./src/settings
SETTINGS_TARGET=libsettings.so
SETTINGS_PATH=settings

MINITUBE_PRO=minitube.pro
MINITUBE_SRC_PATH=./src/minitube
MINITUBE_TARGET=libminitube.so
MINITUBE_PATH=minitube

CPD_PRO=cpd.pro
CPD_SRC_PATH=./src/cpd
CPD_TARGET=cpd

.PHONY: all clean install
.PHONY: dirs common stbapi qtstbapi qtstbapi-compl stbsettings
.PHONY: stbmain cpd settings weather mediaplayer iptvplayer minitube

all: dirs common stbapi qtstbapi qtstbapi-compl stbsettings stbmain weather mediaplayer iptvplayer settings minitube cpd
	$(ECHO) "\n\n\nDONE\n"

dirs:
	$(MKDIR) $(INSTALL) $(SRC)

clean:
	$(RM) $(INSTALL)
	$(RM) $(SRC)

common: dirs
	cd $(SRC);git clone git@$(SRV_NAME):common.git

stbapi: dirs
	cd $(SRC);git clone git@$(SRV_NAME):stbapi.git;cd stbapi/src;make -j8 install

qtstbapi: dirs common stbapi
	cd $(SRC);git clone git@$(SRV_NAME):qtstbapi.git;cd qtstbapi;$(WQMAKE) qtstbapi.pro;make -j8 install

qtstbapi-compl: dirs common stbapi qtstbapi
	cd $(SRC);git clone git@$(SRV_NAME):qtstbapi-compl.git;cd qtstbapi-compl;$(WQMAKE) qtstbapi-compl.pro;make -j8 install

stbsettings: dirs common stbapi
	$(ECHO) "\n\n\nBuilding stbsettings library\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):stbsettings.git
	$(MKDIR) $(EXT_LIB_PATH)
	$(MKDIR) $(EXT_INC_PATH)
	$(RM) $(EXT_LIB_PATH)/$(STBSETTINGS_TARGET)*
	$(RM) $(EXT_INC_PATH)/$(STBSETTINGS_INC)
	cd $(STBSETTINGS_SRC_PATH);$(WQMAKE) $(STBSETTINGS_PRO);make all -j8
	$(CP) $(STBSETTINGS_SRC_PATH)/$(STBSETTINGS_TARGET)* $(EXT_LIB_PATH)
	$(CP) $(STBSETTINGS_SRC_PATH)/$(STBSETTINGS_INC) $(EXT_INC_PATH)

stbmain: dirs common stbsettings qtstbapi qtstbapi-compl
	$(ECHO) "\n\n\nbuilding stbmain!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):stbmain.git
	cd $(STBMAIN_SRC_PATH); $(WQMAKE) $(STBMAIN_PRO);make -j8 install

weather: dirs common
	$(ECHO) "\n\n\nbuilding weather!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):weather.git
	cd $(WEATHER_SRC_PATH); $(WQMAKE) $(WEATHER_PRO);make -j8 install

mediaplayer: dirs common qtstbapi qtstbapi-compl stbsettings
	$(ECHO) "\n\n\nbuilding mediaplayer!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):mediaplayer.git
	cd $(MEDIAPLAYER_SRC_PATH); $(WQMAKE) $(MEDIAPLAYER_PRO);make -j8 install

iptvplayer: dirs common qtstbapi qtstbapi-compl stbsettings
	$(ECHO) "\n\n\nbuilding iptvplayer!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):iptv_new.git
	cd $(IPTVPLAYER_SRC_PATH); $(WQMAKE) $(IPTVPLAYER_PRO);make -j8 install

settings: dirs common stbsettings qtstbapi qtstbapi-compl
	$(ECHO) "\n\n\nbuilding settings!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):settings.git
	cd $(SETTINGS_SRC_PATH); $(WQMAKE) $(SETTINGS_PRO);make -j8 install

minitube: dirs common qtstbapi qtstbapi-compl stbsettings
	$(ECHO) "\n\n\nbuilding minitube!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):minitube.git
	cd $(MINITUBE_SRC_PATH); $(WQMAKE) $(MINITUBE_PRO);make -j8 install

cpd: dirs common
	$(ECHO) "\n\n\nbuilding copy daemon!!!\n\n\n"
	cd $(SRC);git clone git@$(SRV_NAME):cpd.git
	cd $(CPD_SRC_PATH); $(WQMAKE) $(CPD_PRO);make all -j8

install: all
	$(MKDIR) $(INSTALL)/$(INST_LIB_PATH)
	$(CP) $(EXT_LIB_PATH)/* $(INSTALL)/$(INST_LIB_PATH)
	$(CP) $(CPD_SRC_PATH)/$(CPD_TARGET) $(INSTALL)
