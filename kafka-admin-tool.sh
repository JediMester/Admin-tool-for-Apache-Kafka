#!/bin/bash

####################################
#                                  #
#                                  #
# Kreátor: Ujvári Balázs           #	
# Script: kafka-admin-tool         #
# Dátum: 2023.05.31				   #
# Verzió: v1.2               	   #
# A Jedi Tanács nevében            #
# All rights reserved (and stuff)  #                              
#                                  #
#                                  #
####################################

### Location of the functions in the tool and in the .cfg files
### Függvények és azok helye a tool-on és .cfg fájlokon belül
#
## kafka-admin-tool.sh:
# print_help -> line 190
# xIT -> line 195
# resource_check -> line 220,269
# BytesToHuman -> line 365
# countdown -> line 380
# under_rep_checker -> line 391
# sh_mgmt -> line 417
# log_mgmt -> line 454
# log_zipper -> line 472
# is_test_on -> line 488
# is_logging_on -> line 506
# check_error -> line 562
# get_env -> line 581
# validate_environment -> line 587
# get_kaf_ver -> line 600
# create_log_dir -> line 606
# select_random_server -> line 626
# validate_retention_period -> line 637
# offset_date_format -> line 649
# exit_or_restart_or_new_task -> line 675
# get_controller_broker -> line 742
# lets_work -> line 765
# continue_work -> line 887
# work_options -> line 899
#
## csv_functions.cfg:
# task_options -> line 11
# no_csv_provided -> line 40
# simple_csv -> line 1003
# simple_csv_only_topics -> line 1086
# complex_csv -> line 1178
# 
## action_functions.cfg:
# stop_and_disable_kaf_for_loop -> line 16
# start_and_enable_kaf_for_loop -> line 32
# rolling_res_pp_for_loop -> line 49
# rolling_res_for_loop -> line 153
# make_pwd -> line 258
# make_pwd_and_get_controller -> 291
# rolling_restart -> line 355
# stop_and_disable_kaf -> line 690
# start_and_enable_kaf -> line 791
# describe_topic -> line 893
# get_user_acl -> line 906
# get_acl_complex -> line 923
# consume_message -> line 936
# produce_message -> line 944
# last_offset_per_partition -> line 951
# create_topic -> line 958
# create_topic_simple_ot -> line 975
# create_topic_with_retention -> line 1030
# create_consumer_complex_csv -> line 1045
# create_consumer -> line 1070
# create_producer_complex_csv -> line 1128
# create_producer -> line 1153
# add_modify_rights_complex_csv -> line 1223
# add_modify_rights -> line 1244
# add_modify_rights_no_csv_with_transactionalid -> line 1302
# modify_retention_no_csv -> line 1321
# modify_topic_partitions -> line 1341
# reset_offsets -> line 1360
# delete_offsets -> line 1385
#
## user_inputs.cfg:
# desc_topic_inputs -> line 6
# acl_inputs -> line 11
# produce_message_inputs -> line 31
# consume_message_inputs -> line 40
# partition_offset_inputs -> line 48
# topic_only_inputs_no_csv -> line 53
# consumer_rel_inputs_no_csv ->line 73
# producer_rel_inputs_no_csv -> line 80
# modify_rights_inputs -> line 101
# topic_only_inputs_simple_csv_ot -> line 189
# consumer_rel_inputs_simple_csv_ot -> line 195
# offset_inputs -> line 207
#
## node_selector.cfg:
# choose_zookeeper -> line 4
# choose_broker -> line 30

# Színkódok a jobb láthatóság miatt
readonly RED=$'\033[0;31m'    # Red
readonly GRE=$'\033[0;32m'    # Green
readonly YEL=$'\033[1;33m'    # Yellow
readonly LBL=$'\033[1;34m'    # Light blue
readonly LG=$'\033[1;32m'	    # Light green
readonly NC=$'\033[0m'        # No Color --> color off

# Zookeeper-eket és brókereket tartalmazó konfig fájl beszorszolása
envs_cfg=$(locate envs.cfg)
source ${envs_cfg}
#source /home/kafka/kafka-admin-tool/envs.cfg

# User input függvényeket tartalmazó konfig fájl beszorszolása
user_inputs_cfg=$(locate user_inputs.cfg)
source ${user_inputs_cfg}
#source /home/kafka/kafka-admin-tool/user_inputs.cfg

# Action függvényeket tartalmazó konfig fájl beszorszolása
action_functions_cfg=$(locate action_functions.cfg)
source ${action_functions_cfg}
#source /home/kafka/kafka-admin-tool/action_functions.cfg

# CSV related függvényeket tartalmazó konfig fájl beszorszolása
csv_functions_cfg=$(locate csv_functions.cfg)
source ${csv_functions_cfg}
#source /home/kafka/kafka-admin-tool/csv_functions.cfg

# Complex csv case statement-ek
#source /home/kafka/kafka-admin-tool/complex_csv_case_statements.cfg

# Simple csv case statement-ek
function enable_simple_csv() {
	simple_csv_case_statements_cfg=$(locate simple_csv_case_statements.cfg)
	source ${simple_csv_case_statements_cfg}
}
#source /home/kafka/kafka-admin-tool/simple_csv_case_statements.cfg

# Simple_only_topics csv case statement-ek
function enable_simple_ot_csv() {
	simple_ot_csv_case_statements_cfg=$(locate simple_ot_csv_case_statements.cfg)
	source ${simple_ot_csv_case_statements_cfg}
}
#source /home/kafka/kafka-admin-tool/simple_ot_csv_case_statements.cfg

# No csv case statement-ek
no_csv_case_statements_cfg=$(locate no_csv_case_statements.cfg)
source ${no_csv_case_statements_cfg}
#source /home/kafka/kafka-admin-tool/no_csv_case_statements.cfg

# Node (broker/zookeeper) kiválasztó függvények
node_selector_cfg=$(locate node_selector.cfg)
source ${node_selector_cfg}
#source /home/kafka/kafka-admin-tool/node_selector.cfg

# Kafka parancsok
kafka_topics_path="/opt/kafka/apache-kafka/bin/kafka-topics.sh"
kafka_acls_path="/opt/kafka/apache-kafka/bin/kafka-acls.sh"
kafka_configs_path="/opt/kafka/apache-kafka/bin/kafka-configs.sh"
kafka_consumer_gr_path="/opt/kafka/apache-kafka/bin/kafka-consumer-groups.sh"
consumer_properties="/opt/kafka/apache-kafka/config/consumer.properties"
consumer2_properties="/opt/kafka/apache-kafka/config/consumer2.properties"
producer_properties="/opt/kafka/apache-kafka/config/producer.properties"
zookeeper_shell="/opt/kafka/apache-kafka/bin/zookeeper-shell.sh"
kafka_console_producer="/opt/kafka/apache-kafka/bin/kafka-console-producer.sh"
command_config_properties="/opt/kafka/apache-kafka/config/command-config.properties"
kafka_run_class="/opt/kafka/apache-kafka/bin/kafka-run-class.sh"
kafka_opt_dir="/opt/kafka/apache-kafka/"

# Log és egyéb mappák
current_date=$(date +%Y-%m-%d_%H-%M-%S)
log_dir="/opt/kafka/admin-tool-logs/"
log_file="/opt/kafka/admin-tool-logs/admin_tool_exec_${current_date}_.log"
logrow_prefix="["$(who am i | awk '{print $1}')"@"$(hostname)"]$ "
ticket_dir="/home/kafka/kafka-admin-tool/ticketek/"
#ticket_num=""
sh_dir="/home/kafka/kafka-admin-tool/ticketek/sh_dir/"
sh_file="/home/kafka/kafka-admin-tool/ticketek/sh_dir/${current_date}.sh"
kat_dir="/home/kafka/"
pssh_hosts="/home/kafka/pssh_hosts/kaf_hosts"
acl_dir="/home/kafka/kafka-admin-tool/ticketek/acl_dir/"
acl_file="/home/kafka/kafka-admin-tool/ticketek/acl_dir/${current_date}"

# Szigorúan teszt üzemmód --> csak showcase
#TEST=false

declare -a topics

# Logolás beállítása
LOGGING=false

while getopts 'lh' flag; do
  case "${flag}" in
    #t) TEST=true ;;
	l) LOGGING=true ;;
    h|*) print_help ;;
  esac
done
shift "$((OPTIND -1))"

### Függvények definiálása

# Help a script helyes futtatásához

function print_help() {
  echo "Usage: ./kafka-admin-tool.sh [-t] [-l] [-h]"
  exit 1
}

function xIT(){

printf "
 ⢰⠲⢄⡀⠀⠀⠀⠀⠀⡏⠒⠤⡀⠀⠀⠀⠀⠀⠀
⠀⠘⡄⣀⠙⣦⠀⠀⣀⣰⡣⢸⠢⡈⠢⡀⠀⠀⠀⠀
⠀⠀⠸⡰⡰⠈⠉⠉⠀⠀⠀⠈⠑⠰⡀⠘⡄⠀⠀⠀
⠀⠀⢸⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀
⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⠀
⢀⣾⡀⢳⢤⣀⠤⠀⠀⠀⢠⣀⣀⡀⠔⠀⠀⣸⠀⠀
⠘⢦⡀⡎⠀⡼⠁⠀⢻⠃⠀⠸⡄⠀⡅⠀⠈⢽⠀⠀
⠀⠀⠙⠤⣰⠃⠀⠀⠁⡖⠒⢼⡀⠐⣄⠤⠋⠁⠀⠀
⠀⠀⠀⠀⢀⡝⠒⡆⠀⠘⡄⠀⠻⣫⡀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⠊⣀⡼⠀⠀⠀⠈⠢⢀⡠⠃⠀⠀⡰⠊⢱
⠀⠀⠀⠀⠉⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⡠⠊⣠⠔⠁
⠀⠀⠀⠀⠀⢸⠀⢤⠤⠤⠤⢤⠄⡯⠓⠋⠉⠀⠀⠀
⠀⠀⠀⠀⠀⠸⡠⠇⠀⠀⠀⠈⢆⠇⠀⠀⠀⠀
	
	"
		
echo ""

exit 1

}

function resource_check_for_loop() {
	
	controller_host=$(eval echo \${broker_list_${env}}$controller_node)
		
	kaf_broker_list=("${kaf_broker_list[@]/$controller_host}")
	
	kaf_broker_list+=("$controller_host")
	
	for broker in ${kaf_broker_list[@]} 
		do
			broker_host=$(eval echo \${broker_list_${env}}$broker)
			controller_host=$(eval echo \${broker_list_${env}}$controller_node)
			disk_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "df -Ph | awk '{if(\$6 ~ /^\/.+/) print \$5, \$6}' | grep -v '/run*' | grep -v '/boot*' | grep -v '/dev*'")
			#disk_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "df -Ph | awk '{if(\$6 ~ /^\/.+/) print \$5, \$6}' | grep -v '/run*' | grep -v '/boot*' | grep -v '/dev*'")
			cpu_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head")
			#cpu_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head")
			mem_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "grep MemFree /proc/meminfo && grep MemTotal /proc/meminfo")
			#mem_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "grep MemFree /proc/meminfo && grep MemTotal /proc/meminfo")
			load_checker=$(top -b -n 1 | grep 'load average:')
			#broker_status=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "systemctl status kafka | grep -i active | awk '{print \$2 \$3}'")
			broker_status=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "systemctl status kafka | grep 'Active:' | awk '{print \$2 \$3}'")
			#mem_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker} "cat /proc/meminfo | grep MemFree | BytesToHuman && cat /proc/meminfo | grep MemTotal | BytesToHuman")
			os_ver=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "cat /etc/redhat-release")
			echo ""
			echo "${LBL}${broker_host}:${NC}"
			echo ""
			echo "${YEL}Kafka service status:${NC}"
			echo "${broker_status}"
			echo ""
			echo "${YEL}Disk állapota (felhasznált terület %-ban):${NC}"
			echo "${disk_checker}"
			echo ""
			echo "${YEL}Legnagyobb resource igényű process-ek:${NC}"
			echo "${cpu_checker}"
			echo ""
			echo "${YEL}Memória használat:${NC}"
			echo "${mem_checker}"
			echo ""
			echo "${YEL}OS verzió:${NC}"
			echo "${os_ver}"
			echo ""
			echo "${YEL}CPU load:${NC}"
			echo "${load_checker}"
			echo ""
	done
}

# Cluster resource használat csekkolás: mem, CPU load, disk, service státusz, legnagyobb resource igényű process-ek PID-el

function resource_check() {
	
	make_pwd_and_get_controller
	
	#id_rsa="/home/$who_am_i/.ssh/id_rsa"
	
	controller_host=$(eval echo \${broker_list_${env}}$controller_node)
		
	kaf_broker_list=("${kaf_broker_list[@]/$controller_host}")
	
	kaf_broker_list+=("$controller_host")
	
	running=true
	
	for broker in ${kaf_broker_list[@]} 
		do
			if [[ "$running" == "true" ]]; then
				broker_host=$(eval echo \${broker_list_${env}}$broker)
				#controller_host=$(eval echo \${broker_list_${env}}$controller_node)
				disk_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "df -Ph | awk '{if(\$6 ~ /^\/.+/) print \$5, \$6}' | grep -v '/run*' | grep -v '/boot*' | grep -v '/dev*'")
				#disk_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "df -Ph | awk '{if(\$6 ~ /^\/.+/) print \$5, \$6}' | grep -v '/run*' | grep -v '/boot*' | grep -v '/dev*'")
				cpu_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head")
				#cpu_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head")
				mem_checker=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "grep MemFree /proc/meminfo && grep MemTotal /proc/meminfo")
				#mem_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "grep MemFree /proc/meminfo && grep MemTotal /proc/meminfo")
				load_checker=$(top -b -n 1 | grep 'load average:')
				#broker_status=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "systemctl status kafka | grep -i active | awk '{print \$2 \$3}'")
				broker_status=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "systemctl status kafka | grep 'Active:' | awk '{print \$2 \$3}'")
				#mem_checker=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker} "cat /proc/meminfo | grep MemFree | BytesToHuman && cat /proc/meminfo | grep MemTotal | BytesToHuman")
				os_ver=$(sshpass -p $remote_pwd ssh -o stricthostkeychecking=no -A ${who_am_i}@${broker_host} -t "cat /etc/redhat-release")
				echo ""
				echo "${LBL}${broker_host}:${NC}"
				echo ""
				echo "${YEL}Kafka service status:${NC}"
				echo "${broker_status}"
				echo ""
				echo "${YEL}Disk állapota (felhasznált terület %-ban):${NC}"
				echo "${disk_checker}"
				echo ""
				echo "${YEL}Legnagyobb resource igényű process-ek:${NC}"
				echo "${cpu_checker}"
				echo ""
				echo "${YEL}Memória használat:${NC}"
				echo "${mem_checker}"
				echo ""
				echo "${YEL}OS verzió:${NC}"
				echo "${os_ver}"
				echo ""
				echo "${YEL}CPU load:${NC}"
				echo "${load_checker}"
				echo ""
			fi
			
			# Az 's' billentyű lenyomásával stop-olható a for loop, illetve újra elindítható (ha pl. a jelszó átadás az sshpass-nak bug miatt nem sikerül)
			if read -sn 1 -t 0.25 key && [[ "$key" = "s" ]] ; then
				if [[ "$running" == "true" ]]; then
					running=false
					
					rm -rfv $pwd_file
					
					who_am_i="$(who am i | awk '{print $1}')"
	
					pw_dir="/home/kafka/pwd/"
	
					if [[ ! -d $pw_dir ]]; then
						mkdir -p $pw_dir
					fi
	
					pwd_file="$pw_dir$who_am_i.passwd"
	
					if [[ ! -f $pwd_file ]]; then
						touch $pwd_file
						echo "${YEL}IPA jelszó:${NC} "
						read -s pwd && echo $pwd >> $pwd_file
						chmod +rwx $pwd_file
						remote_pwd=$(cat $pwd_file)
					else
						echo "${YEL}IPA jelszó decrypt-álás folyamatban...${NC}"
						echo ""
						remote_pwd=$(cat $pwd_file | openssl enc -base64 -d -salt -pbkdf2 -iter 100000)
					fi
					
					resource_check_for_loop
				else
					running=true
				fi
			fi
	done
	
	
	#break
	#rm -rfv ${pwd_file}
	#echo "${RED}Jelszó fájl törölve.${NC}"
}

# KB --> MB/GB konverter (experimental shit)
function BytesToHuman() {

    read StdIn

    b=${StdIn:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        let s++
    done
    echo "$b$d ${S[$s]}"

}

# Visszaszámláló (countdown) a rolling resihez
function countdown() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        time="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

# URP csekkolás

function under_rep_checker() {
	#choose_broker
	selected_broker=""
	
	get_env
	
	if [[ "$env" == "ua" ]]; then
		selected_broker=$(select_random_server "${broker_list_uat[@]}")
	elif [[ "$env" == "dv" ]]; then
		selected_broker=$(select_random_server "${broker_list_dev[@]}")
	elif [[ "$env" == "pp" ]]; then
		selected_broker=$(select_random_server "${broker_list_pp[@]}")
	else
		selected_broker=$(select_random_server "${broker_list_prod[@]}")
	fi
	
	under_rep_partitions=$($kafka_topics_path --describe --bootstrap-server $selected_broker --under-replicated-partitions --command-config=$consumer_properties | wc -c)
	if [[ ${under_rep_partitions} == 0 ]]; then
		echo "${LBL}URP száma:${NC} ${YEL}${under_rep_partitions}${NC}"
	else
		echo "${LBL}URP száma:${NC} ${RED}${under_rep_partitions}${NC}"
	fi
}

# A futtatható .sh fájlok kezelése és megfelelő formátum kialakítása

function sh_mgmt() {

	dir_with_ticket_num=""
	
	sh_with_ticket_num=""

	if [[ ! -z "$ticket_num" ]]; then
		dir_with_ticket_num="/home/kafka/kafka-admin-tool/ticketek/sh_dir/${ticket_num}/"
		
		sh_dir="$dir_with_ticket_num"
		
		if [[ ! -d "$sh_dir" ]]; then
			mkdir -p "$sh_dir"
		fi
		
		chown -R kafka:kafka "$sh_dir"
		
		sh_with_ticket_num="/home/kafka/kafka-admin-tool/ticketek/sh_dir/${ticket_num}/${ticket_num}_${current_date}.sh"
		
		sh_file="$sh_with_ticket_num"
		
		touch "$sh_file"
		
		chmod +rwx "$sh_file"
	else
		if [[ ! -d "$sh_dir" ]]; then
			mkdir -p "$sh_dir"
		fi
		
		touch "$sh_file"
		
		chmod +rwx "$sh_file"
	fi
}

# Logok kezelése

function log_mgmt() {

	local renamed_log=""
	
	if [[ -d "${log_dir}" ]]; then
		cd "${log_dir}" || exit
	fi
	
	# Ha van jegyszám, akkor belekerül a log nevébe
	if [[ ! -z "$ticket_num" ]]; then
		renamed_log="/opt/kafka/admin-tool-logs/admin_tool_exec_${current_date}_${ticket_num}.log"
		
		log_file="$renamed_log"	
	fi
}

# Log tömörítés (2 napnál idősebb logoknál)

function log_zipper() {
	local zip_day_limit=2
	
	if [[ -d "${log_dir}" ]]; then
		cd "${log_dir}" || exit
	fi
	
	logs_2_b_zipped=$(find . -mtime +"${zip_day_limit}" -type f ! -iname "*gz" | grep log)
        
        for log_to_compress in ${logs_2_b_zipped}; do
            gzip -f -9 "${log_to_compress}"
        done
}

# Teszt üzemmód

function is_test_on() {

if [[ ${TEST} == "true" ]]; then
	echo "${YEL}!! FIGYELEM !! A script jelenleg teszt üzemmódban fut.${NC}"
else
	read -p "Szeretnéd teszt üzemmódban futtatni a script-et? (yes/no) " test_on
	if [[ "$test_on" == "no" ]]; then
		TEST=false
		echo "${YEL}Teszt üzemmód inaktív.${NC}"
	else
		TEST=true
		echo "${YEL}!! FIGYELEM !! A script jelenleg teszt üzemmódban fut.${NC}"
	fi
fi
}

# Logolás beállítása

function is_logging_on() {

if [[ ${LOGGING} == "true" ]]; then
	echo "${LBL}Logolás bekapcsolva.${NC}"
	log_mgmt "$ticket_num"
	exec &> >(tee -ai >(awk -v lrp=$logrow_prefix  '{ print strftime("[%Y-%m-%d %H:%M:%S]")lrp, $0 }' >> ${log_file}) )
	#exec &> >(tee -a ${log_file})
	#exec 2>&1 | tee -a "${log_file}"
	#trap 'echo -n "[$(date -Is)]"' DEBUG
else
	echo "Szeretnéd bekapcsolni a logolást?"
	printf "%s\n" \
	"1. Igen" \
	"2. Nem"
	echo ""
	read -p "Válasz: " logging_on
	
	case $logging_on in
	
	2)
		LOGGING=false
		echo "${LBL}Logolás kikapcsolva.${NC}"
		;;
	
	1)
		LOGGING=true
		echo "${LBL}Logolás bekapcsolva.${NC}"
		log_mgmt "$ticket_num"
		exec &> >(tee -ai >(awk -v lrp=$logrow_prefix  '{ print strftime("[%Y-%m-%d %H:%M:%S]")lrp, $0 }' >> ${log_file}) )
		#exec &> >(tee -a ${log_file})
		;;
		
	esac
	
fi
}

#is_test_on

#logfile="logfile.log"
#logrow_prefix="["$(who am i | awk '{print $1}')"@"$(hostname)"]$ "
#exec &> >(tee -ai >(awk -v lrp=$logrow_prefix  '{ print strftime("[%Y-%m-%d %H:%M:%S]")lrp, $0 }' >> $logfile) )

# Függvény futás eredmény (visszatérési érték)
#function check_function() {
#	local command=$1
#	if [[ "$?" -ne 0 ]]; then
#		return 1
#	else
#		return 0
#	fi
#}


# Hiba csekkolás

function check_error() {
	local command=$1
	shift
	local missing_vars=("$@")
    
	if [[ "$?" -ne 0 ]]; then
		echo "${RED}Hiba történt a(z) $command végrehajtása során.${NC}"
		if [[ ${missing_vars[@]} -gt 0 ]]; then
		echo "Hiányzó változók: "
		for var in "${missing_vars[@]}"; do
			echo "- $var"
		done
		fi
	fi
}

declare env

# Environment beazonosítás
function get_env() {
	env=$(hostname | cut -c 10-11)
}

# Environment validálás

valid_environments=("ua" "dv" "pp" "pr")

function validate_environment() {
  echo "Validálásra érkezett környezet: $1"
  if [[ ! "${valid_environments[@]}" =~ "$1" ]]; then
    echo "${RED}Hibás környezet: $1. A lehetséges környezetek: ua, dv, pp, pr.${NC}"
    exit 1
  fi
  echo "A megadott környezet valid: $1"
}

# Kafka verzió check

function get_kaf_ver() {
	kafka_version=$(kafka-topics.sh --version | cut -c 1-5)
}

# Log mappa kezelés és beállítása

function create_log_dir() {
	if [[ ! -d "$log_dir" ]]; then
		mkdir -p "$log_dir"
		
		chmod -R 766 "$log_dir"
	fi
	
	chown -R kafka:kafka "$log_dir"
}

#function exec_and_log() {
#	exec 3>&1 1>"${log_file}" 2>&1
#	trap "echo '${RED}FIGYELEM: Hiba történt a parancsok végrehajtása során, csekkold le a ${log_file} log fájlt a részletekért.'${NC} >&3" ERR
#	trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG
#}


### Zookeeper és bróker választása -> lokáció: node_selector.cfg fájl

# A szerverek kiválasztása egy véletlenszerűen generált számmal
function select_random_server() {
	printf "%s\n" "${@}" | shuf -n 1
}

# Integer deklarálás
declare -i retention_period
declare -i partitions
declare -i replication_factor

# Retention period validálás

function validate_retention_period() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "${RED}Hiba: A retention_period csak egész szám lehet.${NC}"
    exit 1
  else
	echo "Minden oké, retention_period egy egész szám, gurulhat tovább a szekér."
  fi
}

# Időformat beállítása offset állításhoz/reset-hez
declare formatted_date

function offset_date_format() {
	formatted_date=$(date -d "$offset_date" '+%Y-%m-%dT%H:%M:%S.%3N')
}

# Kilépés, tovább dolgozunk vagy új task indul

function exit_or_restart_or_new_task() {
	
	echo ""
	echo "További lehetőségek:"
	printf "%s\n" \
	"1. Kilépés" \
	"2. Durranhat a következő, hasonló task" \
	"3. Teljesen új task" \
	"4. Vissza a Welcome page-re"
	echo ""
	read -p "Melyik opciót választod? " exit_option
	
	case "$exit_option" in
	1) 
	printf "
 ⢰⠲⢄⡀⠀⠀⠀⠀⠀⡏⠒⠤⡀⠀⠀⠀⠀⠀⠀
⠀⠘⡄⣀⠙⣦⠀⠀⣀⣰⡣⢸⠢⡈⠢⡀⠀⠀⠀⠀
⠀⠀⠸⡰⡰⠈⠉⠉⠀⠀⠀⠈⠑⠰⡀⠘⡄⠀⠀⠀
⠀⠀⢸⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀
⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⠀
⢀⣾⡀⢳⢤⣀⠤⠀⠀⠀⢠⣀⣀⡀⠔⠀⠀⣸⠀⠀
⠘⢦⡀⡎⠀⡼⠁⠀⢻⠃⠀⠸⡄⠀⡅⠀⠈⢽⠀⠀
⠀⠀⠙⠤⣰⠃⠀⠀⠁⡖⠒⢼⡀⠐⣄⠤⠋⠁⠀⠀
⠀⠀⠀⠀⢀⡝⠒⡆⠀⠘⡄⠀⠻⣫⡀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⠊⣀⡼⠀⠀⠀⠈⠢⢀⡠⠃⠀⠀⡰⠊⢱
⠀⠀⠀⠀⠉⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⡠⠊⣠⠔⠁
⠀⠀⠀⠀⠀⢸⠀⢤⠤⠤⠤⢤⠄⡯⠓⠋⠉⠀⠀⠀
⠀⠀⠀⠀⠀⠸⡠⠇⠀⠀⠀⠈⢆⠇⠀⠀⠀⠀
	
	"
		
		echo ""
		
		if [[ -z $there_is_csv ]]; then
			exit 1
		else
			echo "${LBL}Szoszi van a bablevesben Bástyám? Mielőtt itt hagysz egyedül és magányosan, itt vannak az időközben legenerált .sh fájlaid.${NC} "
			echo "${GRE}A generálódott .sh fájl(ok):${NC}"
			
			if [[ "$sh_dir" != "$sh_dir" ]]; then
				for file in "${sh_files[@]}"; do
					echo "${YEL}${file}${NC}"
				done
			else
				echo "${YEL}${sh_file}${NC}"
			fi
			
			exit 1
		fi
		;;
		
	2)
		continue_work
		;;
		
	3)
		work_options
		;;
	
	4)
		lets_work
		;;
	
	esac
	
}

function get_controller_broker() {
	
	choose_zookeeper
	controller_broker=$($zookeeper_shell $selected_zookeeper get /brokers/ids/$(/opt/kafka/apache-kafka/bin/zookeeper-shell.sh $selected_zookeeper get /controller | tail -1 | jq .brokerid) | tail -1 | jq .endpoints[])
	#controller_node=$(echo $controller_broker | awk -F "//" {'print $2'} | awk -F '"' {'print $1'} | cut -c1-36)
	#controller_node=$(echo $controller_broker | grep "SASL_SSL" | sed 's/.*\///' | awk -F '"' {'print $1'} | cut -c1-31)
	if [[ ${env} == "pp" ]]; then
		controller_node=$(echo $controller_broker | grep "SASL_SSL" | sed 's/.*\///' | awk -F '"' {'print $1'} | cut -c1-35)
	else
		controller_node=$(echo $controller_broker | grep "SASL_SSL" | sed 's/.*\///' | awk -F '"' {'print $1'} | cut -c1-31)
	fi
	controller_status=$(sshpass -f $pwd_file ssh -o stricthostkeychecking=no -A ${who_am_i}@${controller_node} "systemctl status kafka | grep -i active | awk '{print \$2 \$3}'")
	echo "${LBL}Jelenleg a kontroller bróker a cluster-ben:${NC} ${YEL}$controller_node${NC}"
	echo ""
	echo "${LBL}Service státusz:${NC} ${YEL}$controller_status${NC}"
	
}


### CSV fájl/no CSV

# CSV fájlból dolgozunk-e vagy sem + csv fájltípus bekérése

function lets_work() {
	
	printf "
  __      __        __                                  __            ____  __   ________________
 /  \    /  \ ____ |  |  ____   ____   _____   ____   _/  |_  ____   |    |/ _| /  _  \__    ___/
 \   \/\/   // __ \|  | /  __\ /  _ \ /     \_/ __ \  \   __\/  _ \  |      <  /  /_\  \|    |   
  \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/   |  | (  <_> ) |    |  \/    |    \    |   
   \__/\__/  \____>|____/\____>\____/|__|_|__/\____>   |__|  \____/  |____|__ \____|____/____|
"
   
	echo ""
	
	printf "%s\n" \
	"${YEL}A script használati lehetőségei:" \
	"-h -> help" \
	"-l -> logolás bekapcsolása${NC}" \
	""
	
	printf "%s\n" \
	"${YEL}A logokat az alábbi helyen tárolja a script:${NC}" \
	"${LBL}$log_dir${NC}" \
	"${YEL}Alias hozzá:${NC} ${GRE}atl${NC}" \
	"${YEL}Kafka ticketek mappája:${NC}" \
	"${LBL}$ticket_dir${NC}" \
	"${YEL}Alias hozzá:${NC} ${GRE}kti${NC}" \
	"${YEL}Futtatandó sh-k mappája:${NC}" \
	"${LBL}/home/kafka/kafka-admin-tool/ticketek/sh_dir/${NC}" \
	"${YEL}Alias hozzá:${NC} ${GRE}shd${NC}" \
	"" \
	""

	printf "%s\n" \
	"${LG}!!!FONTOS INFO!!!${NC}" \
	"${YEL}HA az IPA pw decrypt-álás után az sshpass nem eszi meg a jelszót (sshpass bug...), akkor az ${RED}'s'${NC} ${YEL}betű lenyomásával a loop/függvény megállítható!${NC}" \
	"${YEL}Ezután újra meg kell adni az IPA jelszót és a loop/függvény újraindul!${NC}" \
	"${YEL}Előfordulási lehetőségek:${NC}" \
	"- Cluster INFO" \
	"- Rolling restart" \
	"- Cluster/site stop + start" \
	"" \
	""
	
	printf "%s\n" \
    "${YEL}1. Cluster INFO:${NC}" \
	"- disk használat" \
	"- memória használat" \
	"- CPU load" \
	"- URP" \
	"- controller bróker" \
	"- aktuális Kafka verzió" \
    "${YEL}2. Plusz feature bekapcsolása:${NC}" \
	"a) csak topic-ot tartalmazó xls/csv feldolgozás" \
	"b) topic-ot és user-t tartalmazó xls/csv feldolgozás" \
	"c) mindkettő bekapcsolása" \
    "${YEL}3. TOVÁBB a munkavégzésre" \
	"4. Kilépés${NC}" \
	""

    read -p "Válasz: " info_or_work
	echo ""
    case $info_or_work in

    1)
        resource_check
        echo ""
		
		under_rep_checker
        echo ""

        get_controller_broker
        echo ""

        get_kaf_ver
        echo "${LBL}Kafka verzió:${NC} ${YEL}$kafka_version${NC}"
        echo ""
		
		#rm -rfv ${pwd_file}
		#echo "${RED}Jelszó fájl törölve.${NC}"
		#echo ""

		echo "${LG}IPA jelszó encrypt-álás folyamatban...${NC}"
		echo $pwd | openssl enc -base64 -e -salt -pbkdf2 -iter 100000 >> $pwd_file
		echo ""
		echo "${LG}Jelszó levédve.${NC}"
		echo ""
		
        printf "%s\n" \
		"${YEL}1. Tovább a munkavégzésre" \
		"2. Vissza a Welcome page-re" \
		"3. Kilépés${NC}" \
		""

        read -p "Válasz: " work_or_exit
        case $work_or_exit in

        1)
            work_options

            ;;

        3)
            xIT

            ;;
		2)
			lets_work
			;;
        esac
        ;;
    2)
        work_options

        ;;
	4)
		xIT
		;;
	2)
		echo ""
		read -p "Kérlek válassz egy lehetőséget: " option
		echo ""
		
		case $option in
		
		a)
			enable_simple_csv
			;;
		b)
			enable_simple_ot_csv
			;;
		c)
			enable_simple_csv
			enable_simple_ot_csv
			;;
		esac
		;;
    esac
}

function continue_work() {

#if [[ ! -z $there_is_csv ]]; then
if [[ $ticket_or_admin_task == "1" ]]; then

	complex_csv
else
	no_csv_provided
	
fi
}

function work_options() {

    printf "%s\n" \
	"" \
    "Kafka jegyet csinálnál vagy egyéb adminisztratív task-ot végeznél?" \
    "1. ${YEL}Kafka jegy (.csv fájl feldolgozás)${NC}" \
    "2. ${YEL}Adminisztratív task:" \
	"- rolling restart" \
	"- Kafka service stop/start (cluster vagy site) " \
	"- üzenet consume-olás/produce-olás" \
	"- ACL lekérdezés" \
	"- offset állítás/törlés/reset" \
	"- topic describe-olás" \
	"- partíció szám állítás" \
	"- retention period állítás" \
	"- egyedi command megadása (új login shell-ben - experimental shit)" \
	"- topic(ok) törlése" \
	"- jogosultság(ok) elvétele/törlése" \
	"- stb.${NC}" \
	"3. ${LBL}Vissza a Welcome page-re${NC}" \
	"4. ${RED}Kilépés${NC}" \
	""

    echo ""
    read -p "Válasz: " ticket_or_admin_task

    case ${ticket_or_admin_task} in

    1)
		printf "%s\n" \
		"Milyen fajta .csv fájl-t fogsz megadni?" \
		"${YEL}1 - simple ->${NC} ${LBL}a .csv fájl csak topic és user oszlopokat tartalmaz${NC}" \
		"${YEL}2 - complex ->${NC} ${LBL}több paraméterrel rendelkező .csv (a megbeszélt excel template alapján ki/feltöltött fájl)${NC}" \
		"${YEL}3 - simple_only_topics ->${NC} ${LBL}a .csv fájl csak topic oszlopot tartalmaz${NC}" \
		""
			
		read -p "Kérlek válassz egyet: " csv_file_type
			
		#echo "Belépés a ${LBL}$ticket_dir${NC} mappába..."
		#sleep 0.5
		#		
		#cd "$ticket_dir" && pwd && ls -alh
		
		case "$csv_file_type" in
			
		1)
			#read -p "Kérlek válaszd ki a .csv fájlodat: " csv_file
			
			simple_csv # Lokáció: csv_functions.cfg fájl
			
			simple_csv_case # Lokáció: simple_csv_case_statements.cfg fájl
			;;
				
		2)
			#read -p "Kérlek válaszd ki a .csv fájlodat: " csv_file
			
			complex_csv # Lokáció: csv_functions.cfg fájl
			;;
				
		3)
			#read -p "Kérlek válaszd ki a .csv fájlodat: " csv_file
			
			simple_csv_only_topics # Lokáció: csv_functions.cfg fájl
			
			simple_ot_csv_case # Lokáció: simple_ot_csv_case_statements.cfg fájl
			;;
				
			esac
        ;;

    2)
        ##rolling_restart
		no_csv_provided
        ;;
    3)
		lets_work
		;;
	
	4)
		xIT
		;;

	esac

}

# Port beállítása (zookeeper/bootstrap server)
zk_port=2181

bts_port=9092

# Day --> millisec konverzió
#day_to_ms_retention="$(( 86400000 * retention_period ))"

# Csekkolja, hogy meg van-e adva retention
function retention_check_and_convert() {
	if [[ -z ${retention_period} ]]; then
		day_to_ms_retention=604800000   # Default = 7 nap
	else
		day_to_ms_retention="$(( 86400000 * retention_period ))"
	fi
}
### Action-ök végrehajtása

# CSV case statement-ek futása adott action választása alapján 
#--> Lokáció: no_csv_case_statements.cfg, complex_csv_case_statements.cfg, simple_csv_case_statements.cfg, simple_ot_csv_case_statements.cfg

# Dógozzunk :D

lets_work