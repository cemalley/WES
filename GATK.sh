#!/bin/bash

module load GATK
module load bwa
module load picard
module load R
module load samtools
module load annovar

REF='/fdb/GATK_resource_bundle/hg38bundle/Homo_sapiens_assembly38.fasta'

ID='CT01'

cd /data/NCATS_ifx/data/WES/

java -jar /usr/local/apps/picard/2.17.11/picard.jar MarkDuplicates \
  INPUT=${ID}/${ID}.bam \
  OUTPUT=${ID}/${ID}_dedup.bam \
  METRICS_FILe=metrics.txt

java -jar picard.jar BuildBamIndex \
    INPUT=${ID}/${ID}_dedup.bam

GATK -m 7g RealignerTargetCreator \
  -R $REF \
  -I ${ID}/${ID}_dedup.bam \
  -o ${ID}/${ID}_realignment_targets.list

GATK -m 7g \
  -T IndelRealigner \
  -R $REF \
  -I ${ID}/${ID}_dedup.bam \
  -targetIntervals ${ID}/${ID}_realignment_targets.list \
  -o ${ID}/${ID}_realigned_reads.bam

GATK -m 7g HaplotypeCaller \
  -R $REF \
  -I ${ID}/${ID}_realigned_reads.bam \
  -o vcf/${ID}_raw_variants.vcf \
  --genotyping_mode DISCOVERY \
  -stand_call_conf 30

cd ./vcf

V=${ID}_raw_variants.vcf

GATK -m 7g SelectVariants \
  -R $REF \
  -V $V \
  -selectType SNP \
  -o ${ID}_SNP_raw.vcf

GATK -m 7g SelectVariants \
-R $REF \
-V $V \
-selectType INDEL \
-o ${ID}_INDEL_raw.vcf


# sbatch --mem=10g --gres=lscratch:10 scripts/GATK.sh # 14165511

# then filter variants
# then BQSR
# then analyze covariates
# then apply BQSR
# then parse metrics
# then run annovar


