#!/bin/bash
#
# name          : wanip_log
# desciption    : show and temporary log LAN and WAN Information
# autor         : Speefak ( itoss@gmx.de )
# licence       : (CC) BY-NC-SA
# version	: 3.0
#
#------------------------------------------------------------------------------------------------------------
############################################################################################################
#######################################   define global variables   ########################################
############################################################################################################
#------------------------------------------------------------------------------------------------------------
 TMPFILE=/tmp/waniplog
 DELAY=9
 WANIP_0=000.000.000.000-$(date +%s)											# set first startparameter
 WANIP_1=$WANIP_0													# set first startparameter
 WANIP_2=$WANIP_0													# set first startparameter
 WANIP_3=$WANIP_0													# set first startparameter
 #WANIP=$(wget -q -O - http://www.nwlab.net/cgi-bin/show-ip-js | cut -d'>' -f2 | cut -d '<' -f 1 | sed -ne '2p')	# HTTPS no
 #WANIP=$(wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')				# HTTPS no

#------------------------------------------------------------------------------------------------------------
############################################################################################################
###########################################   define functions   ###########################################
############################################################################################################
#-------------------------------------------------------------------------------------------------------------------------------------------------------
usage() {
	printf "\n usage : $(basename $0) -<option>\n\n"
	printf "        -s = Screenlog\n"
	printf "        -f = Filelog in $TMPFILE\n\n"
	exit
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------
ip_request_loop () {

	while true ; do

		WANIP=$(wget -q -O - http://www.nwlab.net/cgi-bin/show-ip-js | cut -d'>' -f2 | cut -d '<' -f 1 | sed -ne '2p')		# get actual WAN IP
		if [ "$(echo $WANIP_0|cut -d - -f1)" == "$WANIP" ] ; then								# check if ip has changed
			echo "No change for WANIP $WANIP"
		else
			WANIP_3=$WANIP_2												# log step 3 from logstep 2
			WANIP_2=$WANIP_1												# log step 2 from logstep 1
			WANIP_1=$WANIP_0												# log step 1 from logstep 0
			WANIP_0=$WANIP-$(date +%s)											# log step 0 get actual IP
			echo "WANIP change on $(date) from $(echo $WANIP_1|cut -d - -f1) to $(echo $WANIP_0|cut -d - -f1)"
		fi

		if [[ "$LOGART" == "s" ]] ; then						
			clear
			printf "\n\n"
			printf " $(hostname) @ $(hostname -I)\n\n"
			printf " WANIP operating IP => $(echo $WANIP_0|cut -d - -f1) \n"						# show 0 operating IP
			echo " WANIP $(printf %03d $(($(date +%s)-$(echo $WANIP_1|cut -d - -f2)))) sec. ago =>" $WANIP_1| cut -d - -f1	# show 1 last IP filter timcode
			echo " WANIP $(printf %03d $(($(date +%s)-$(echo $WANIP_2|cut -d - -f2)))) sec. ago =>" $WANIP_2| cut -d - -f1	# show 2 last IP filter timcode
			echo " WANIP $(printf %03d $(($(date +%s)-$(echo $WANIP_3|cut -d - -f2)))) sec. ago =>" $WANIP_3| cut -d - -f1	# show 3 last IP filter timcode
			printf "\n"
			for i in `seq $DELAY -1 0` ;do
				echo -en "\015\033[K Next IP check in $i"
				read -t 1 -N 1 INPUT
				if [[ -n $INPUT ]]; then
			   		printf "\n"
	 				exit
			   	fi
			done

		elif [[ "$LOGART" == "f" ]] ; then
			echo "Delay = $DELAY" 												 > $TMPFILE
			echo "WANIP operating IP =>" $(date -d @$(echo $WANIP_0|cut -d - -f2)) "=>"  $(echo $WANIP_0|cut -d - -f1)	>> $TMPFILE
			echo "WANIP operating IP =>" $(date -d @$(echo $WANIP_1|cut -d - -f2)) "=>"  $(echo $WANIP_1|cut -d - -f1)	>> $TMPFILE
			echo "WANIP operating IP =>" $(date -d @$(echo $WANIP_2|cut -d - -f2)) "=>"  $(echo $WANIP_2|cut -d - -f1)	>> $TMPFILE
			echo "WANIP operating IP =>" $(date -d @$(echo $WANIP_3|cut -d - -f2)) "=>"  $(echo $WANIP_3|cut -d - -f1)	>> $TMPFILE
			sleep $DELAY
		fi
done
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------
############################################################################################################
#############################################   start script   #############################################
############################################################################################################
#------------------------------------------------------------------------------------------------------------

	case $1 in
		-f ) LOGART=f;;
		-s ) LOGART=s;;
		*  ) usage;;
	esac

#------------------------------------------------------------------------------------------------------------

	#  start IP request loop
	ip_request_loop

#------------------------------------------------------------------------------------------------------------
############################################################################################################
##############################################   changelog   ###############################################
############################################################################################################
#------------------------------------------------------------------------------------------------------------
# TODO => update for IPv6




