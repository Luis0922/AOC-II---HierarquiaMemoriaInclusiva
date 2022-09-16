module hierarquiaMemoria(clock, cren, endereco, dado_in,dado_out, hit, LRU, dirty, validade,es, tagV1, tagV2, dado_cache_V1, dado_cache_V2, write_back);
	
	input clock, cren;
	input [4:0] endereco;
	input [2:0] dado_in;
	
	output [2:0] dado_out;
	output hit;
	output [1:0] LRU;
	output [1:0] dirty;
	output [1:0] validade;
	output [2:0] es;
	output [2:0] tagV1;
	output [2:0] tagV2;
	output [2:0] dado_cache_V1;
	output [2:0] dado_cache_V2;
	output write_back;
	
	wire [4:0]endereco_ram;
	wire wren;
	wire [2:0] dado_ram;
	wire [2:0] q;

	cache L1(clock, q, cren, endereco, dado_in,dado_out, hit, wren, dado_ram, endereco_ram, LRU, dirty, validade,es, tagV1, tagV2, dado_cache_V1, dado_cache_V2);
	ramlpm ram(endereco_ram, clock, dado_ram, wren, q);

	assign write_back = wren;
	
endmodule
