
# # Script PowerShell para Avaliação de Banco de Dados

# Este script PowerShell realiza uma rápida análise do ambiente do SQL Server, verificando a fragmentação de índices, a última atualização de estatísticas e o status do banco. É útil para identificar possíveis melhorias, como rebuilds e reorganizações de índices.

# ## Instruções de Uso

# 1. Substitua as variáveis `$serverInstance`, `$database`, `$username` e `$password` pelos valores apropriados.
# 2. Execute o script para obter informações sobre fragmentação de índices, estatísticas e status do banco.
# 3. Utilize os resultados para sugerir melhorias no desempenho do banco de dados.

# **Autor:** [contatogabrielpinto@gmail.com]
# **Data de Criação:** [23/12/2023]



# Importa o módulo SqlServer
Import-Module SqlServer

# Parâmetros de conexão com o SQL Server
$serverInstance = "Adcionar o nome da instância"
$database = "inserir o nome do banco que deseja validar"
$username = "acessar com o usuario do privilegio admin"
$password = "inserir-senha"
#$port     = '1433'
# Consulta SQL a ser executada

try {
    $sqlQueryStatus = "SELECT
    name AS DatabaseName,
    state_desc AS DatabaseState
FROM
    sys.databases
WHERE
    state_desc = 'ONLINE';"

    # Cria a string de conexão
    $connectionString = "Server=$serverInstance;Database=$database;User Id=$username;Password=$password;"
    # Executa a consulta SQL usando o cmdlet Invoke-Sqlcmd
    $results = Invoke-Sqlcmd -Query $sqlQueryStatus -ConnectionString $connectionString

    Write-Host "STATUS DO BANCO"
    $results | Format-Table
   

}
catch {
    # Bloco que será executado se ocorrer uma exceção
    Write-Host "Ocorreu um erro: $($_.Exception.Message)"
    # Outras ações de tratamento de erro, se necessário
}

try {
    $sqlQuerylisdbs = "SELECT
 dbschemas.[name] as 'Schema',
 dbtables.[name] as 'Table',
 dbindexes.[name] as 'Index',
 indexstats.avg_fragmentation_in_percent
 FROM
 sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
 INNER JOIN
 sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
 INNER JOIN
 sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
 INNER JOIN
 sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
 AND indexstats.index_id = dbindexes.index_id
 WHERE
 indexstats.avg_fragmentation_in_percent > 20
 ORDER BY
 indexstats.avg_fragmentation_in_percent DESC;"

    # Cria a string de conexão
    $connectionString = "Server=$serverInstance;Database=$database;User Id=$username;Password=$password;"
    # Executa a consulta SQL usando o cmdlet Invoke-Sqlcmd
    $result1 = Invoke-Sqlcmd -Query $sqlQuerylisdbs -ConnectionString $connectionString

    Write-Host "Porcentagem de fragmentacao do Idx"
    $result1 | Format-Table
    
}
catch {
    # Bloco que será executado se ocorrer uma exceção
    Write-Host "Ocorreu um erro: $($_.Exception.Message)"
    # Outras ações de tratamento de erro, se necessário
}

try {
    $sqlQueryListStatistic = "SELECT
    o.name AS TableName,
      i.name AS IndexName,
      STATS_DATE(o.object_id, i.index_id) AS LastUpdated
  FROM
      sys.objects AS o
  INNER JOIN
      sys.indexes AS i ON o.object_id = i.object_id
  WHERE
      o.type = 'U' AND
      i.index_id > 0 AND
      STATS_DATE(o.object_id, i.index_id) < DATEADD(DAY, -30, GETDATE());
      SELECT
      o.name AS TableName,
      i.name AS IndexName,
      STATS_DATE(o.object_id, i.index_id) AS LastUpdated
  FROM
      sys.objects AS o
  INNER JOIN
      sys.indexes AS i ON o.object_id = i.object_id
  WHERE
      o.type = 'U' AND
     i.index_id > 0 AND
     STATS_DATE(o.object_id, i.index_id) < DATEADD(DAY, -30, GETDATE());"

    # Cria a string de conexão
    $connectionString = "Server=$serverInstance;Database=$database;User Id=$username;Password=$password;"
    # Executa a consulta SQL usando o cmdlet Invoke-Sqlcmd
    $result2 = Invoke-Sqlcmd -Query $sqlQueryListStatistic -ConnectionString $connectionString

    Write-Host "Ultimo Update de estatistica"
    $result2 | Format-Table
  
}
catch {
    # Bloco que será executado se ocorrer uma exceção
    Write-Host "Ocorreu um erro: $($_.Exception.Message)"
   
}




