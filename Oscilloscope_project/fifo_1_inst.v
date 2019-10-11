fifo_1	fifo_1_inst (
	.aclr ( aclr_sig ),
	.clock ( clock_sig ),
	.data ( data_sig ),
	.rdreq ( rdreq_sig ),
	.wrreq ( wrreq_sig ),
	.empty ( empty_sig ),
	.full ( full_sig ),
	.q ( q_sig )
	);
