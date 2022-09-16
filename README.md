# AOC-II---Pratica-1---HierarquiaMemoriaInclusiva

Objetivo: Esta prática tem a finalidade de exercitar os conceitos relacionados à hierarquia de
memória.
-----------------------------------------------------------------------------------------------
Parte I (4 pontos): 
-----------------------------------------------------------------------------------------------
  Implementação de uma memória RAM utilizando a biblioteca LPM. Aparte I do arquivo 
PraticaI_ingles.pdf apresenta uma orientação de como utilizar a biblioteca. O teste 
deve ser realizado utilizando o número de ordem de chamada da dupla. Devem ser realizadas 
duas escritas em posições distintas da memória e em seguida a leitura destas posições.
-----------------------------------------------------------------------------------------------
 Parte II (4 pontos): 
 -----------------------------------------------------------------------------------------------
  Inicialização da memória utilizando um arquivo (MIF - memory initialization file (MIF)). As 
duas primeiras posições da memória devem conter o número de chamada da dupla e as demais 
posições devem ser números sequenciais ao maior número dentre eles. A parte V do arquivo 
PraticaI_ingles.pdf apresenta uma orientação de como utilizar a biblioteca.
-----------------------------------------------------------------------------------------------
 Parte III (12 pontos): 
 -----------------------------------------------------------------------------------------------
  Implementação de uma hierarquia de memória inclusiva. Implemente uma cache L1 e memória
principal no esquema de hierarquia inclusiva. A cache L1 é de 2 vias e a memória principal é 
diretamente mapeada. A atualização da memória principal ocorre utilizando a política de Write-Back. 
A memória principal deve ser criada utilizando a biblioteca da LPM. O aluno deve mostrar os casos 
de acerto e falha de leitura/escrita na cache e situações que modificam os bits “Dirty”, “LRU” e 
“Válido”. A memória principal e a cache devem ser inicializadas de acordo com os testes disponibilizados.
