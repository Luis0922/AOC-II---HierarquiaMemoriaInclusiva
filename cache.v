module cache(clock, q, cren, endereco, dado_in, dado_out, hit, wren, dado_ram, endereco_ram, LRU, dirty, validade, es, tagV1, tagV2, dado_cache_V1, dado_cache_V2);

	// dados que vem da CPU
	input clock, cren;	
	input [4:0] endereco;
	input [2:0] dado_in;
	
	// dados que vão para a RAM
	output [2:0] dado_ram;
	output [4:0] endereco_ram;
	output wren;
	
	// dado que retorna da RAM para a cache
	input [2:0] q;
	
	// dados que saem da cache
	output hit;
	output [1:0] LRU;
	output [1:0] dirty;
	output [1:0] validade;
	output [2:0] dado_out;
	output [2:0] es;
	output [2:0] tagV1;
	output [2:0] tagV2;
	output [2:0] dado_cache_V1;
	output [2:0] dado_cache_V2;
	
	// dados temporarios
	reg temp_hit;
	reg temp_wren;
	reg [2:0] temp_dadoRam;
	reg [4:0] temp_endereco;
	reg [2:0] dado;
	reg [4:0] reg_endereco;
	

	// dado que salva o endereco anterior
	reg [4:0] bufferEndereco;
	
	// variavel que guarda o estado atual da cache
	reg [2:0] estado;
	
	// via 1 da cache
	reg bits_validade_via1 [3:0];
	reg bits_dirty_via1 [3:0];
	reg bits_LRU_via1 [3:0];
	reg [2:0] tag_via1 [3:0];
	reg [2:0] dado_armazenado_via1 [3:0];
	reg [2:0] reg_dado_cache_V1;
	reg [2:0] reg_dado_cache_V2;
	
	// via 2 da cache
	reg bits_validade_via2 [3:0];
	reg bits_dirty_via2 [3:0];
	reg bits_LRU_via2 [3:0];
	reg [2:0] tag_via2 [3:0];
	reg [2:0] dado_armazenado_via2 [3:0];
	
	integer i;
	
	// via 1 da cache
	wire validadev1;
	wire dirtyv1;
	wire LRUv1;
	wire [2:0] tagv1;
	wire [2:0] dadov1;
	
	// via 2 da cache
	wire validadev2;
	wire dirtyv2;
	wire LRUv2;
	wire [2:0] tagv2;
	wire [2:0] dadov2;
	
	initial begin
		estado = 3'b000;
		
		// via 1
		bits_validade_via1[0] = 0;
		bits_validade_via1[1] = 1;
		bits_validade_via1[3] = 1;
		bits_LRU_via1[0] = 0;
		bits_LRU_via1[1] = 0;
		bits_LRU_via1[3] = 1;
		bits_dirty_via1[0] = 0;
		bits_dirty_via1[1] = 0;
		bits_dirty_via1[3] = 0;
		tag_via1[0] = 3'b100;
		tag_via1[1] = 3'b000;
		dado_armazenado_via1[0] = 3'b011;
		dado_armazenado_via1[1] = 3'b011;
		dado_armazenado_via1[3] = 3'b011;
		
		//via 2
		bits_validade_via2[0] = 1;
		bits_validade_via2[1] = 1;
		bits_LRU_via2[0] = 1;
		bits_LRU_via2[1] = 1;
		bits_dirty_via2[0] = 0;
		bits_dirty_via2[1] = 0;
		tag_via2[0] = 3'b101;
		tag_via2[1] = 3'b001;
		dado_armazenado_via2[0] = 3'b100;
		dado_armazenado_via2[1] = 3'b111;
		
	end 
	
	always @(posedge clock) 
	begin
		if(estado == 3'b000)
		begin
			
			// guarda o endereço atual
			temp_endereco = endereco;
			reg_endereco = endereco;
			
			if(cren == 0) // leitura
			begin
					
				//limpa os compara
				temp_hit = 1'b0;
				
				temp_wren = 1'b0;
				
				// se os bits de validade das vias nao sao validos
				if((~validadev1) & (~validadev2))
				begin
					estado = 3'b010;
				end
				
				// via 1 não é lixo de memória e confere se a tag da via 1 bate com a do endereco
				else if(validadev1 && (endereco[4:2] == tagv1))
				begin
					// hit = 1 | altera LRU (1 0) | pega o dado
					temp_hit = 1;
					bits_LRU_via1[endereco[1:0]] = 1'b1;
					bits_LRU_via2[endereco[1:0]] = 1'b0;
					dado = dadov1;
				end
				
				// via 2 não é lixo de memória e confere se a tag da via 2 bate com a do endereco
				else if(validadev2 && endereco[4:2] == tagv2)
				begin
					// hit = 1 | altera LRU (0 1) | pega o dado
					temp_hit = 1;
					bits_LRU_via2[endereco[1:0]] = 1'b1;
					bits_LRU_via1[endereco[1:0]] = 1'b0;
					dado = dadov2;
				end
				
				else
				// caso no qual é valido mas não bate nehuma tag
				begin
					
					
					estado = 3'b010;
					
					// confere se o conjunto da via 1 é o mais recente 
					if((~LRUv1) && dirtyv1)
					begin
						
						//guarda o endereço atual para usar futuramente na leituta
						bufferEndereco = endereco;						
						temp_dadoRam = dadov1;
						
						//guarda o endereco contido na tag+indice para saber onde escrever na memoria
						temp_endereco[4:2] = tagv1;
						temp_endereco[1:0] = endereco[1:0];
						
						// dirty = 0 | wren = 1
						bits_dirty_via1[endereco[1:0]] = 1'b0;
						
						temp_wren = 1'b1;
						estado = 3'b001;
						
					end
					
					// confere se o conjunto da via 2 é o mais recente 
					else if(dirtyv2 && (~LRUv2))
					begin
						
						//guarda o endereço atual para usar futuramente na leituta
						bufferEndereco = endereco;						
						temp_dadoRam = dadov2;
						
						//guarda o endereco contido na tag+indice para saber onde escrever na memoria
						temp_endereco[4:2] = tagv2;
						temp_endereco[1:0] = endereco[1:0];
						
						bits_dirty_via2[endereco[1:0]] = 0;
						temp_wren = 1;
						estado = 3'b001;
						
					end
	
				end
					
			end
				
			else // escrita
			begin
			
				// se bate a tag da via 1 com o endereco
				if(endereco[4:2] == tagv1) 
				begin
					// via 1
					// hit = 1 | escreve o dado na cache | escreve a tag na cache | validade = 1 | dirty = 1 |
					// altera LRU (1 0)
					dado_armazenado_via1[endereco[1:0]] = dado_in;
					tag_via1[endereco[1:0]] = endereco[4:2];
					bits_validade_via1[endereco[1:0]] = 1'b1;
					bits_dirty_via1[endereco[1:0]] = 1'b1;
					bits_LRU_via1[endereco[1:0]] = 1'b1;
					bits_LRU_via2[endereco[1:0]] = 1'b0;
					temp_hit = 1;				
					
				end
				
				// se bate a tag da via 2 com o endereco
				else if(endereco[4:2] == tagv2)
				begin
					// via 2
					// hit = 1 | escreve o dado na cache | escreve a tag na cache | validade = 1 | dirty = 1 |
					// altera LRU (0 1)
					dado_armazenado_via2[endereco[1:0]] = dado_in;
					tag_via2[endereco[1:0]] = endereco[4:2];
					bits_validade_via2[endereco[1:0]] = 1'b1;
					bits_dirty_via2[endereco[1:0]] = 1'b1;
					bits_LRU_via2[endereco[1:0]] = 1'b1;
					bits_LRU_via1[endereco[1:0]] = 1'b0;
					
					temp_hit = 1;
					
				end
				
				else
				begin
					
					// se nenhum dos casos anteriores acontecerem o hit = 0
					temp_hit = 0;
					
					// procura o LRU que foi acessado a mais tempo
					
					// via 1
					if(~LRUv1)
					begin
						
						// write miss com write back
						// se o dirty e a validade da via 1 forem = 1
						
						if(dirtyv1 & validadev1)
						begin
							// dado que vai para a RAM recebe o dado que estava na cache da via 1 |
							// cria um novo endereco com a tag e o indice que estavam na cache
							// wren = 1
							temp_dadoRam = dadov1;
							temp_endereco[4:2] = tagv1;
							temp_endereco[1:0] = endereco[1:0];
							temp_wren = 1;
							estado = 3'b100;
						end
						
						// escreve o novo dado na via 1 com a tag e indice enviados pela CPU
						// validade = 1 | LRU (1 0) | dirty = 1 |
						bits_validade_via1[endereco[1:0]] = 1'b1;
						bits_LRU_via1[endereco[1:0]] = 1'b1;
						bits_LRU_via2[endereco[1:0]] = 1'b0;
						bits_dirty_via1[endereco[1:0]] = 1'b1;
						tag_via1[endereco[1:0]] = endereco[4:2];
						dado_armazenado_via1[endereco[1:0]] = dado_in;
					
					end
					
					// via 2
					else
					begin
					
						// write miss com write back
						// se o dirty e a validade da via 2 forem = 1
						if(dirtyv2 & validadev2)
						begin
							// dado que vai para a RAM recebe o dado que estava na cache da via 2 |
							// cria um novo endereco com a tag e o indice que estavam na cache
							// wren = 1
							temp_dadoRam = dadov2;
							temp_endereco[4:2] = tagv2;
							temp_endereco[1:0] = endereco[1:0];
							temp_wren = 1;
							estado = 3'b100;
						end	
						
						// escreve o novo dado na via 2 com a tag e indice enviados pela CPU
						// validade = 1 | LRU (0 1) | dirty = 1 |
						bits_validade_via2[endereco[1:0]] = 1;
						bits_LRU_via2[endereco[1:0]] = 1;
						bits_LRU_via1[endereco[1:0]] = 0;
						bits_dirty_via2[endereco[1:0]] = 1;
						tag_via2[endereco[1:0]] = endereco[4:2];
						dado_armazenado_via2[endereco[1:0]] = dado_in;
					
					end
					
				end
				
			end
			
		end
		
		// caso haja buffer deve-se escrever na memoria
		else if(estado == 3'b001)
		begin
			temp_wren = 0;
			estado = 3'b010;
			temp_endereco = bufferEndereco;
		end
		
		// estado para saltar 1 ciclo de clock
		else if(estado == 3'b010)
		begin
			//temp_wren = 0;
			estado = 3'b011;
		end
		
		else if(estado == 3'b011)
		begin
		
			// confere se o conjunto da via 1 é o mais recente
			if(~LRUv1)  
			begin
				// pega o dado da ram
				bits_LRU_via1[temp_endereco[1:0]] = 1'b1;
				bits_LRU_via2[temp_endereco[1:0]] = 1'b0;
				bits_validade_via1[temp_endereco[1:0]] = 1'b1;
				//mudei de temp para buffer
				tag_via1[temp_endereco[1:0]] = temp_endereco[4:2];
				dado_armazenado_via1[temp_endereco[1:0]] = q;
				dado = q;
			end
			
			// confere se o conjunto da via 2 é o mais recente
			else  
			begin
				// pega o dado da ram
				bits_LRU_via2[temp_endereco[1:0]] = 1'b1;
				bits_LRU_via1[temp_endereco[1:0]] = 1'b0;
				bits_validade_via2[temp_endereco[1:0]] = 1'b1;
				//mudei de temp para buffer
				tag_via2[temp_endereco[1:0]] = temp_endereco[4:2];
				dado_armazenado_via2[temp_endereco[1:0]] = q;
				dado = q;
			end					
			
			estado = 3'b000;
			
		end
		else
		begin
			temp_wren = 0;
			estado = 3'b000;
			// dado = q;
		end
				
	end
	
	assign validadev1 = bits_validade_via1[endereco[1:0]];
	assign dirtyv1 = bits_dirty_via1[endereco[1:0]];
	assign LRUv1 = bits_LRU_via1[endereco[1:0]];
	assign tagv1 = tag_via1[endereco[1:0]]; 
	assign dadov1 = dado_armazenado_via1[endereco[1:0]];
	
	// via 2 da cache
	assign validadev2 = bits_validade_via2[endereco[1:0]];
	assign dirtyv2 = bits_dirty_via2[endereco[1:0]];
	assign LRUv2 = bits_LRU_via2[endereco[1:0]];
	assign tagv2 = tag_via2[endereco[1:0]];
	assign dadov2 = dado_armazenado_via2[endereco[1:0]];
	
	// saber qual estado esta
	assign es = estado;
	
	// sai para o CPU
	assign dirty[1] = bits_dirty_via1[endereco[1:0]];
	assign dirty[0] = bits_dirty_via2[endereco[1:0]];
	
	assign LRU[1] = bits_LRU_via1[endereco[1:0]];
	assign LRU[0] = bits_LRU_via2[endereco[1:0]];
	
	assign validade[1] = bits_validade_via1[endereco[1:0]];
	assign validade[0] = bits_validade_via2[endereco[1:0]];
	
	assign tagV1 = tag_via1[endereco[1:0]];
	assign tagV2 = tag_via2[endereco[1:0]];
	
	assign dado_cache_V1 = dado_armazenado_via1[endereco[1:0]];
	assign dado_cache_V2 = dado_armazenado_via2[endereco[1:0]];
	
	assign dado_out = dado;
	assign hit = temp_hit;
	
	// sai para a RAM
	assign endereco_ram = temp_endereco[3:0];
   assign dado_ram = temp_dadoRam;
	assign wren = temp_wren;
	
	
	
endmodule
