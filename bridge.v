write address channel

write data channel

write response channel

read address channel

read data channel

read response channel


apb bridge states

idle:
	if((write_happened && axi_bready)||(!write_happened))
		if ((axi_read_address_valid) && ((apb_master_state == idle) || (apb_master_state == Access)))
			nxt_state = axi_read
			To DO:
				capture address
				initiate transfer on apb master

		else if((axi_write_address_valid) && (axi_write_data_valid) && (apb_master_state == idle))
			nxt_state = axi_write
			To DO:
				capture address
				capture data
				initiate transfer on apb master

		else if(!(axi_write_address_valid) && (axi_write_data_valid) && (apb_master_state == idle))
			nxt_state = axi_write_wait
			To DO:
				capture data
				do not initiate transfer on apb master
		else if((axi_write_address_valid) && !(axi_write_data_valid) && (apb_master_state == idle))
			nxt_state = axi_write_wait
			To DO:
				capture address
				do not initiate transfer on apb master
		write_happened = false

	else if(write_happened && !axi_bready)
		nxt_state = idle


axi_read:
	if ((apb_master_state == Access) && (apb_slave_pready))
		if (axi_read_ready)
			if ((axi_write_address_valid) && (axi_write_data_valid))
					nxt_state = axi_write		
				To DO:
					capture address
					capture data
					initiate transfer on apb master

			elseif ((axi_write_address_valid) && (!axi_write_data_valid))
					nxt_state = axi_write_data_wait				
				To DO:
					capture address
					

			elseif ((!axi_write_address_valid) && (axi_write_data_valid))
					nxt_state = axi_write_address_wait				
			To DO:
				capture data
				send read data response
				send read data back to axi master
				assert read valid signal
		else 
			nxt_state = axi_read_response_send_wait
			To DO:
				capture data
				assert read valid signal

	else if ((apb_master_state == Access) && (!apb_slave_pready))
		
		if(wait_counter<max_count)
			nxt_state = axi_read;
			To Do:
				
		else 
			nxt_state = idle;
			To Do:
				send error respone through axi read response channel
	else:
		nxt_state = axi_read;

axi_write:
	if ((apb_master_state == Access) && (apb_slave_pready))
		nxt_state = idle 
		To DO:
			write_happend = true
			capture_write_data_response
			assert write valid response

	else if ((apb_master_state == Access) && (!apb_slave_pready))
		
		if(wait_counter<max_count)
			nxt_state = axi_write;
			To Do:
		else 
			nxt_state = idle;
			To Do:
				send error respone through axi write response channel
	else:
		nxt_state = axi_write;


axi_write_data_wait:
	if(axi_write_data_valid)
		nxt_state = axi_write;
		To Do:
			capture write data
	else:
		nxt_state = axi_write_data_wait;


axi_write_address_wait:
	if(axi_write_data_valid)
		nxt_state = axi_write;
		To Do:
			capture write address
	else:
		nxt_state = axi_write_address_wait;

axi_read_response_send_wait:

	if (axi_read_ready)
		if ((axi_write_address_valid) && (axi_write_data_valid))
				nxt_state = axi_write		
			To DO:
				capture address
				capture data
				initiate transfer on apb master

		elseif ((axi_write_address_valid) && (!axi_write_data_valid))
				nxt_state = axi_write_data_wait				
			To DO:
				capture address
				

		elseif ((!axi_write_address_valid) && (axi_write_data_valid))
				nxt_state = axi_write_address_wait				
		To DO:
			send read data response
			send read data back to axi master
			assert read valid signal
	else 
		nxt_state = axi_read_response_send_wait



