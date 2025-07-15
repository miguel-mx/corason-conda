#!/bin/bash

# =================== FUNANNOTATE PIPELINE ===================
# Author: https://github.com/pyrosilesl97
# Description: Clean, mask, and annotate multiple genome files using Funannotate.
# Supports input formats: .fna, .fa, .fasta

# ======================= USAGE ========================
show_help() {
    echo ""
    echo "Usage:"
    echo "  bash $0 <GENOME_DIR> <OUT_DIR_BASE> <TMP_DIR> <CPUS> <AUGUSTUS_SPECIES> <BUSCO_DB> <BUSCO_SEED> <SPECIES_NAME>"
    echo ""
    echo "Arguments:"
    echo "  GENOME_DIR         Directory with input genome files (.fna, .fa, .fasta)"
    echo "  OUT_DIR_BASE       Base output directory for funannotate results"
    echo "  TMP_DIR            Temporary directory to store simplified genome headers"
    echo "  CPUS               Number of CPUs to use for processing"
    echo "  AUGUSTUS_SPECIES   Augustus species model to use"
    echo "  BUSCO_DB           BUSCO database (e.g., fungi, bacteria)"
    echo "  BUSCO_SEED         Seed species for BUSCO"
    echo "  SPECIES_NAME       Full species name in quotes (e.g., \"Aspergillus fumigatus\")"
    echo ""
    echo "Example:"
    echo "  bash $0 ./genomes ./out ./tmp 8 aspergillus fungi aspergillus_fumigatus \"Aspergillus fumigatus\""
    echo ""
    echo "Note: All arguments are required."
    echo ""
    exit 1
}

# =================== HELP TRIGGER ====================
if [[ "$1" == "--help" || "$1" == "-h" || "$#" -ne 8 ]]; then
    show_help
fi

# ==================== PARÁMETROS ====================
GENOME_DIR="$1"
OUT_DIR_BASE="$2"
TMP_DIR="$3"
CPUS="$4"
AUGUSTUS_SPECIES="$5"
BUSCO_DB="$6"
BUSCO_SEED="$7"
SPECIES_NAME="$8"

mkdir -p "$TMP_DIR"

# ===================== LOOP PRINCIPAL =====================
for GENOME in "$GENOME_DIR"/*.{fna,fa,fasta}; do
    [ -e "$GENOME" ] || continue

    BASENAME=$(basename "$GENOME")
    BASENAME_NOEXT="${BASENAME%%.*}"
    SHORT_GENOME="${TMP_DIR}/${BASENAME_NOEXT}_short.fasta"
    OUT_DIR="${OUT_DIR_BASE}/${BASENAME_NOEXT}"

    echo "✂️  Recortando headers de $BASENAME..."
    awk '/^>/ {printf(">contig_%d\n", ++i); next} {print}' "$GENOME" > "$SHORT_GENOME"

    echo "🚀 Procesando $BASENAME_NOEXT..."
    mkdir -p "$OUT_DIR"

    funannotate clean -i "$SHORT_GENOME" -o "${OUT_DIR}/genome.cleaned.fasta"
    funannotate mask -i "${OUT_DIR}/genome.cleaned.fasta" -o "${OUT_DIR}/genome.masked.fasta"

    funannotate predict \
        -i "${OUT_DIR}/genome.masked.fasta" \
        -o "$OUT_DIR" \
        --species "$SPECIES_NAME" \
        --strain "$BASENAME_NOEXT" \
        --isolate "$BASENAME_NOEXT" \
        --cpus "$CPUS" \
        --augustus_species "$AUGUSTUS_SPECIES" \
        --busco_db "$BUSCO_DB" \
        --busco_seed_species "$BUSCO_SEED"

    echo "✅ Terminado: $BASENAME"
    echo "---------------------------------------"
done
