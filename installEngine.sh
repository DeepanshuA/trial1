#!/bin/bash
# ====================================
# InstallEngine.sh
# ----------------
# Function:
# Copies all jars from ARC_REPORTGENERATOR-XTP lib to ARC Report Genenerator lib directory
# Copies jars from RANARC codebase to ARC Report Genenerator lib directory
# Copies all files from ARC_REPORTGENERATOR-XTP conf to ARC Report Genenerator conf directory
#
# ====================================


############# Begin: Functions ##################
# Gets ARC Report Generator Path

New_passed_successfully="0"
Old_passed_successfully="0"

# Gets option of Install or Upgrade the component
InputInstallUpgrade(){
	InstallUpgrade=
	echo
	read -e -p 'Enter:
	1 New Install
	2 Copy XTP ReportEngine post ARC Report Generator Upgrade
	3 Upgrade - XTP ReportEngine:
	' InstallUpgrade
	if [[ $InstallUpgrade = "" ]]; then
		echo
		echo This option can not be blank, Try Again.
		InputInstallUpgrade
	fi
	if [[ $InstallUpgrade != "1" && $InstallUpgrade != "2" && $InstallUpgrade != "3" ]] ; then 
		echo
		echo $InstallUpgrade option is not valid, Try Again.
		InputInstallUpgrade
	fi	

}

InputARCRepGenPath() {
         if [[ $InstallUpgrade -eq "1" || $InstallUpgrade -eq "3" ]]; then 
			if [[ $New_passed_successfully -eq "0" ]]; then
				echo 
				read -e -p  'Enter ARC Report Generator component path (e.g. /opt/bin/ARCReportGenerator<version>) : ' ARCRepGenPath
				checkDirectoryExistence $ARCRepGenPath
				checkNecessarySubDirectoriesExistence $ARCRepGenPath "lib"
				ARCRepGenLibPath=$ARCRepGenNecessarySubDirectoryPath
				New_passed_successfully="1"
			fi
		 elif [[ $InstallUpgrade -eq "2" ]]; then 
			if [[ $New_passed_successfully -eq "0" ]]; then
				echo 
				read -e -p  'Enter New ARC Report Generator component path (e.g. /opt/bin/ARCReportGenerator<version>) : ' ARCRepGenPath
				checkDirectoryExistence $ARCRepGenPath
				checkNecessarySubDirectoriesExistence $ARCRepGenPath "lib"
				ARCRepGenLibPath=$ARCRepGenNecessarySubDirectoryPath
				New_passed_successfully="1"
			fi	
			if [[ $Old_passed_successfully -eq "0" ]]; then
				echo 
				read -e -p  'Enter Old ARC Report Generator component path (e.g. /opt/bin/ARCReportGenerator<version>) : ' oldARCRepGenPath
				checkDirectoryExistence $oldARCRepGenPath
				checkNecessarySubDirectoriesExistence $oldARCRepGenPath "lib"
				OldARCRepGenLibPath=$ARCRepGenNecessarySubDirectoryPath
				checkNecessarySubDirectoriesExistence $oldARCRepGenPath "config"
				OldARCRepGenConfigPath=$ARCRepGenNecessarySubDirectoryPath
				checkNecessarySubDirectoriesExistence $oldARCRepGenPath "install"
				OldARCRepGenInstallPath=$ARCRepGenNecessarySubDirectoryPath
				Old_passed_successfully="1"
			fi
		 fi	
}

checkDirectoryExistence() {
         if  !([ -e "$1" ]) then
                echo ARC Report Generator path "$1" does not exist, Try Again.
                InputARCRepGenPath
         fi
}

checkNecessarySubDirectoriesExistence() {
		 ARCRepGenNecessarySubDirectoryPath=$1/$2/
		 if  !([ -e "$ARCRepGenNecessarySubDirectoryPath" ]) then
				echo ARC Report Generator path should contain a $2 folder. "$ARCRepGenNecessarySubDirectoryPath" does not exist, Try Again.
				InputARCRepGenPath
		 fi
}

correctUrl() {
		corUrl=$1
		corUrl="${corUrl//\"}"
		corUrl=$(echo $corUrl | tr -d '\r')
		corUrl="$(set -f; echo $corUrl)"
		corUrl=$(echo "$corUrl" | sed 's/\/*$//')
}

# Gets Domain file path as input
 InputETDRepEngPath() {
                ETDRepEngPath=
                ETDRepEngLibPath=
                echo
                read -e -p 'Enter Tracker Package Folder (e.g. /opt/bin/temp/ARC_REPORTGENERATOR-XTP) : ' ETDRepEngPath

                if  !([ -e "$ETDRepEngPath" ]) then
                 echo Tracker Package Folder path "$ETDRepEngPath" does not exist, Try Again.
                 InputETDRepEngPath
                fi

                ETDRepEngLibPath=$ETDRepEngPath/lib/
                if  !([ -e "$ETDRepEngLibPath" ]) then
                 echo Tracker Package Folder path should contain a lib folder. "$ETDRepEngLibPath" does not exist, Try Again.
                 InputETDRepEngPath
                fi
}

InputSourceSystemType() {
                SourceSytemType=
                TemplateFolderPath=
                echo
                read -e -p 'Enter Source system type ( (1)Ransys/(2)Xtp/(3)Risc ) : ' SourceSytemType
                
                if [[ $SourceSytemType != "1" && $SourceSytemType != "2" && $SourceSytemType != "3" ]] ; then 
                    echo
                    echo $SourceSytemType option is not valid, Try Again.
                    InputSourceSystemType
                fi
               

case $SourceSytemType in
					1) TemplateFolderPath=$ETDRepEngPath/jasperTemplates/ransys/ ;;
					2) TemplateFolderPath=$ETDRepEngPath/jasperTemplates/xtp/ ;;
					3) TemplateFolderPath=$ETDRepEngPath/jasperTemplates/risc/ ;;
esac

                echo ~~~~~~~~ Template folder path is "$TemplateFolderPath" ~~~~~~~~ 

				if  !([ -e "$TemplateFolderPath" ]) then
                 echo "$TemplateFolderPath" does not exist, Try Again.
                 InputSourceSystemType
                fi
}

############# End: Functions ####################

InputInstallUpgrade;
InputARCRepGenPath;
if [[ $InstallUpgrade -eq "1" || $InstallUpgrade -eq "3" ]]; then
		InputETDRepEngPath
		InputSourceSystemType;
fi

echo
echo

echo ~~~~~~~~ Changing current directory to Report Generator lib path : "$ARCRepGenLibPath" ~~~~~~~~
cd "$ARCRepGenLibPath"

echo ~~~~~~~~ If exists then delete groovy jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo
echo
if [ $(find . -maxdepth 1 -name "groovy*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting groovy*.jar ..
	rm -f groovy*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete itext jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo
echo
if [ $(find . -maxdepth 1 -name "itext*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting itext*.jar ..
	rm -f itext*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete xercesImpl jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo
echo
if [ $(find . -maxdepth 1 -name "xercesImpl*.jar" -type f | wc -l) -gt 0 ]
then
        echo Deleting xercesImpl*.jar ..
        rm -f xercesImpl*.jar
        echo
fi

echo ~~~~~~~~ If exists then delete xml-apis jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo
echo
if [ $(find . -maxdepth 1 -name "xml-apis*.jar" -type f | wc -l) -gt 0 ]
then
        echo Deleting xml-apis*.jar ..
        rm -f xml-apis*.jar
        echo
fi

echo ~~~~~~~~ If exists then delete report_generator_core jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "report_generator_core*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting report_generator_core*.jar ..
	rm -f report_generator_core*.jar
	echo
fi

echo ~~~~~~~~ Delete com.iontrading.arcreporting jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo Deleting com.iontrading.arcreporting*.jar ..
rm -f com.iontrading.arcreporting*.jar
echo

echo ~~~~~~~~ If exists then delete arc-common jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "arc-common-*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting arc-common-*.jar ..
	rm -f arc-common-*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete arc-remoting jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "arc-remoting-*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting arc-remoting-*.jar ..
	rm -f arc-remoting-*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete arc-sql jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "arc-sql-*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting arc-sql-*.jar ..
	rm -f arc-sql-*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete jasperreport jar file from "$ARCRepGenLibPath" ~~~~~~~~
echo
echo
if [ $(find . -maxdepth 1 -name "jasperreports*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting jasperreports*.jar ..
	rm -f jasperreports*.jar
	echo
fi

echo ~~~~~~~~ If exists then delete yes-all jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "yes-all*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting yes-all*.jar ..
	rm -f yes-all*.jar
fi

echo ~~~~~~~~ If exists then delete bootstrap jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "bootstrap*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting bootstrap*.jar ..
	rm -f bootstrap*.jar
fi

echo ~~~~~~~~ If exists then delete legacy-build jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "legacy-build*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting legacy-build*.jar ..
	rm -f legacy-build*.jar
fi

echo ~~~~~~~~ If exists then delete jdbc-driver jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "jdbc-driver*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting jdbc-driver*.jar ..
	rm -f jdbc-driver*.jar
fi

echo ~~~~~~~~ If exists then delete connector jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "connector*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting connector*.jar ..
	rm -f connector*.jar
fi

echo ~~~~~~~~ If exists then delete mkv_wrappers jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "mkv_wrappers*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting mkv_wrappers*.jar ..
	rm -f mkv_wrappers*.jar
fi

echo ~~~~~~~~ If exists then delete jmix_platform jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "jmix_platform*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting jmix_platform*.jar ..
	rm -f jmix_platform*.jar
fi

echo ~~~~~~~~ If exists then delete jmix_application jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "jmix_application*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting jmix_application*.jar ..
	rm -f jmix_application*.jar
fi

echo ~~~~~~~~ If exists then delete jmix_logging jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "jmix_logging*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting jmix_logging*.jar ..
	rm -f jmix_logging*.jar
fi

echo ~~~~~~~~ If exists then delete configuration_core jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "configuration_core*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting configuration_core*.jar ..
	rm -f configuration_core*.jar
fi

echo ~~~~~~~~ If exists then delete tracing jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "tracing*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting tracing*.jar ..
	rm -f tracing*.jar
fi

echo ~~~~~~~~ If exists then delete commons-lang jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "commons-lang*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting commons-lang*.jar ..
	rm -f commons-lang*.jar
fi

echo ~~~~~~~~ If exists then delete commons-beanutils jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "commons-beanutils*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting commons-beanutils*.jar ..
	rm -f commons-beanutils*.jar
fi

echo ~~~~~~~~ If exists then delete aopalliance jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "aopalliance*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting aopalliance*.jar ..
	rm -f aopalliance*.jar
fi

echo ~~~~~~~~ If exists then delete guava jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "guava*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting guava*.jar ..
	rm -f guava*.jar
fi

echo ~~~~~~~~ If exists then delete guice jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "guice*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting guice*.jar ..
	rm -f guice*.jar
fi

echo ~~~~~~~~ If exists then delete modules_annotations jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "modules_annotations*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting modules_annotations*.jar ..
	rm -f modules_annotations*.jar
fi

echo ~~~~~~~~ If exists then delete proguard_annotations jar file from "$ARCRepGenLibPath" ~~~~~~~~
if [ $(find . -maxdepth 1 -name "proguard_annotations*.jar" -type f | wc -l) -gt 0 ]
then
	echo Deleting proguard_annotations*.jar ..
	rm -f proguard_annotations*.jar
fi	
	
echo ~~~~~~~~ Downloading files from "$ARCCodebaseJarsPath" to "$ARCRepGenLibPath" ~~~~~~~~
echo

echo ~~~~~~~~ Changing current directory to install home path ~~~~~~~~
cd -

declare -i CopyErr=0
declare -i XCopErr=0

echo
echo
echo
echo ~~~~~~~~ Copying config, install and template folder files to "$ARCRepGenPath" ~~~~~~~~
echo

case $InstallUpgrade in
 
					1) cp -Rvf $ETDRepEngPath/config $ARCRepGenPath/.
					   cp -Rvf $ETDRepEngPath/install $ARCRepGenPath/.
					   cp -Rvf $TemplateFolderPath $ARCRepGenPath/jasperTemplates
					if [ $? -ne 0 ]
						then
						CopyErr=1
					fi
					;;
					2) cp -Rvf $oldARCRepGenPath/config $ARCRepGenPath/.
					   cp -Rvf $oldARCRepGenPath/install $ARCRepGenPath/.
					   cp -Rvf $oldARCRepGenPath/jasperTemplates $ARCRepGenPath
					   cp -Rvf $oldARCRepGenPath/jasperTemplates_backup $ARCRepGenPath
					if [ $? -ne 0 ]
						then
						CopyErr=1
					fi
					;;
					3) rsync -av --progress $ETDRepEngPath/config/* $ARCRepGenPath/config/. --exclude parameterMappingEnvSpecific.properties
					   cp -Rvf $ETDRepEngPath/install $ARCRepGenPath/.
					   if [ -d "$ARCRepGenPath/jasperTemplates_backup/" ]; then
						   find $ARCRepGenPath/jasperTemplates_backup/ -type f -delete
						   cp -Rvf $ARCRepGenPath/jasperTemplates/* $ARCRepGenPath/jasperTemplates_backup/
					   else
						   rsync -av --progress $ARCRepGenPath/jasperTemplates/* $ARCRepGenPath/jasperTemplates_backup
					   fi
						   find $ARCRepGenPath/jasperTemplates/ -type f -delete
						   cp -Rvf $TemplateFolderPath/* $ARCRepGenPath/jasperTemplates/
esac	

 
if [[ $InstallUpgrade -eq "1" || $InstallUpgrade -eq "3" ]]; then
		
		echo
		echo
		echo ~~~~~~~~ Copying all jars from "$ETDRepEngPath/lib/" to "$ARCRepGenLibPath" ~~~~~~~~
		echo
		echo ~~~~~~~~ If exists then delete $ARCRepGenLibPath/ARC_REPORTGENERATOR-XTP*.jar ~~~~~~~~
		files=$(ls $ARCRepGenLibPath/ARC_REPORTGENERATOR-XTP*.jar 2> /dev/null | wc -l)
		if [ **"$files" != "0"** ]
		then
				echo Deleting $ARCRepGenLibPath/ARC_REPORTGENERATOR-XTP*.jar ..
				rm -f $ARCRepGenLibPath/ARC_REPORTGENERATOR-XTP*.jar
				echo
		fi

		echo Copying files from $ETDRepEngPath/lib/
		cp -Rvf $ETDRepEngLibPath/*.jar $ARCRepGenLibPath/.
			ls $ETDRepEngLibPath > $ARCRepGenPath/install/JarsFromXTPRE.txt
		if [ $? -ne 0 ]
		then
		CopyErr=1
		fi
		
elif [[ $InstallUpgrade -eq "2" ]]; then

		while read jarFile
		do
				echo
				echo Copying files from $OldARCRepGenLibPath
				cp -Rvf $OldARCRepGenLibPath/$jarFile $ARCRepGenLibPath/.
				if [ $? -ne 0 ]
				then
				CopyErr=1
				fi
		done < $OldARCRepGenInstallPath/JarsFromXTPRE.txt
fi	 
    
echo
echo CopyErr $CopyErr
echo XCopErr $XCopErr

if [[ $CopyErr -eq 0 && $XCopErr -eq 0 ]]
        then
        echo
        echo
        echo ==================== Batch Result ===========================================
        echo File update for ETD Report Engine completed.
        echo =============================================================================
        echo
        echo
        echo
        exit 0
else
        echo
        echo
        echo
        echo ==================== Batch Result ===========================================
        echo Batch reported error, please check exception/error detail in console output.
        echo =============================================================================
        echo
        echo
        echo
        exit 1
fi
