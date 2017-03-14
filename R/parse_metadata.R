metadata <- read.table('../metadata/E-GEUV-1.sdrf.txt', header = TRUE, sep = '\t',
  stringsAsFactors = FALSE)
full_data <- read.table('../metadata/PRJEB3366.txt', header = TRUE, sep = '\t',
  stringsAsFactors = FALSE)

tmp <- dplyr::group_by(metadata, Source.Name)
tmp <- dplyr::summarize(tmp, left = Comment.FASTQ_URI.[1], right = Comment.FASTQ_URI.[2])
tmp <- dplyr::rename(tmp, sample = Source.Name)

clean_metadata <- dplyr::select(metadata, sample = Source.Name,
  ena_sample = Comment.ENA_SAMPLE., ena_run = Comment.ENA_RUN.,
  assay_name = Assay.Name, population = Characteristics.population.,
  laboratory = Factor.Value.laboratory.)
clean_metadata <- dplyr::distinct(clean_metadata)

checksum <- dplyr::select(full_data, ena_run = run_accession,
  md5 = fastq_md5)
checksum <- dplyr::mutate(checksum,
  md5_left = sapply(strsplit(md5, ';'), '[[', 1),
  md5_right = sapply(strsplit(md5, ';'), '[[', 2))
checksum <- dplyr::select(checksum, -md5)

res <- dplyr::inner_join(tmp, clean_metadata, by = 'sample')
res <- dplyr::inner_join(res, checksum, by = 'ena_run')

rm(tmp)

md5_table <- dplyr::do(dplyr::group_by(res, sample), {
  data.frame(md5 = c(.$md5_left, .$md5_right),
    fastq = paste0('rna/', .$sample, '/', .$sample, '_', 1:2, '.fastq.gz')
    )
})
md5_table <- dplyr::ungroup(md5_table)

write.table(dplyr::select(md5_table, -sample), '../metadata/fastq.md5',
  sep = '  ', quote = FALSE, row.names = FALSE, col.names = FALSE)

write.table(res, '../metadata/clean.tsv', sep = '\t', quote = FALSE,
  row.names = FALSE, col.names = FALSE)
