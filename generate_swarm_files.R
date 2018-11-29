samples <- c('CT01','CT02','CT03','CT04', 'CT05','CT06')

# GATK reference genome hg38
ref <- '/fdb/GATK_resource_bundle/hg38bundle/Homo_sapiens_assembly38.fasta'

# Align
for (i in samples){
  cat('bwa mem -t 8 -R "@RG\\tID:CT05\\tPL:Illumina\\tSM:',i,'" /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex/genome.fa <(zcat fastq/',i,'_R1_001.fastq.gz) <(zcat fastq/',i,'_R2_001.fastq.gz) | samtools view -bS - | samtools sort - > ',i,'/',i,'.bam; samtools index ',i,'/',i,'.bam', sep='')
  cat('\n\n')
}

# Mark duplicates
for (i in samples){
  cat('cd /data/NCATS_ifx/data/WES/ && java -jar /usr/local/apps/picard/2.17.11/picard.jar MarkDuplicates INPUT=',i,'/',i,'.bam OUTPUT=',i,'/',i,'_dedup.bam METRICS_FILE=metrics_',i,'.txt', sep='')
  cat('\n\n')
}


# Caller
for (i in samples){
  cat('cd /data/NCATS_ifx/data/WES/ && GATK -m 15g HaplotypeCaller -R ',ref,' -I ',i,'/',i,'_dedup.bam -o vcf/',i,'_raw_variants.vcf --genotyping_mode DISCOVERY -stand_call_conf 30 --dbsnp /fdb/GATK_resource_bundle/hg38bundle/dbsnp_146.hg38.vcf.gz -L /data/NCATS_ifx/data/WES/hglft_genome_subset.bed', sep='')
  cat('\n\n')
}


#  

# ${ID}/${ID} --> ',i,'/',i,'
