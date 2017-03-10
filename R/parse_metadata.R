metadata <- read.table('../metadata/E-GEUV-1.sdrf.txt', header = TRUE, sep = '\t',
  stringsAsFactors = FALSE)

tmp <- dplyr::group_by(metadata, Source.Name)
tmp <- dplyr::summarize(tmp, left = Comment.FASTQ_URI.[1], right = Comment.FASTQ_URI.[2])
tmp <- dplyr::rename(tmp, sample = Source.Name)

clean_metadata <- dplyr::select(metadata, sample = Source.Name, ena_sample = Comment.ENA_SAMPLE.,
  assay_name = Assay.Name, population = Characteristics.population.,
  laboratory = Factor.Value.laboratory.)
clean_metadata <- dplyr::distinct(clean_metadata)

res <- dplyr::inner_join(tmp, clean_metadata, by = 'sample')

write.table(res, '../metadata/clean.tsv', sep = '\t', quote = FALSE,
  row.names = FALSE, col.names = FALSE)
