import os
import sys
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from pathlib import Path

def clean_directories(output_dir):
    genomes_path = output_dir / "GENOMES"
    ids_path = output_dir / "Corason_Rast.IDs"

    if genomes_path.exists():
        for f in genomes_path.glob("*"):
            f.unlink()
    else:
        genomes_path.mkdir(parents=True)

    if ids_path.exists():
        ids_path.unlink()

def format_rast_id(count):
    return f"1{count:05d}"

def parse_gbk(gbk_file, rast_id, output_dir):
    faa_path = output_dir / "GENOMES" / f"{rast_id}.faa"
    txt_path = output_dir / "GENOMES" / f"{rast_id}.txt"

    with open(faa_path, "w") as faa_out, open(txt_path, "w") as txt_out:
        txt_out.write("contig_id\tfeature_id\ttype\tlocation\tstart\tstop\tstrand\tfunction\tlocus_tag\tfigfam\tspecies\tnucleotide_sequence\tamino_acid\tsequence_accession\n")

        for seq_record in SeqIO.parse(gbk_file, "genbank"):
            accession = seq_record.id
            locus = seq_record.name
            species = "unknown"
            if seq_record.annotations.get("organism"):
                species = seq_record.annotations["organism"]

            count = 1
            for feature in seq_record.features:
                if feature.type == "CDS" and 'translation' in feature.qualifiers:
                    start = int(feature.location.start) + 1
                    end = int(feature.location.end)
                    strand = "+" if feature.location.strand == 1 else "-"
                    if strand == "-":
                        start, end = end, start

                    product = feature.qualifiers.get("product", ["hypothetical protein"])[0]
                    locus_tag = feature.qualifiers.get("locus_tag", ["NA"])[0]
                    translation = feature.qualifiers["translation"][0].replace("*", "")

                    feature_id = f"fig|666666.{rast_id}.peg.{count}"
                    txt_out.write(f"{locus}\t{feature_id}\ttype\tlocation\t{start}\t{end}\t{strand}\t{product}\t{accession}\tfigfam\t{species}\tnuc\t{translation}\t{locus_tag}\n")

                    seq_record_out = SeqRecord(Seq(translation), id=feature_id, description="")
                    SeqIO.write(seq_record_out, faa_out, "fasta")

                    count += 1

def main(gbk_dir, output_dir):
    gbk_dir = Path(gbk_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "GENOMES").mkdir(exist_ok=True)

    clean_directories(output_dir)

    rast_ids_path = output_dir / "Corason_Rast.IDs"
    gbk_files = sorted(gbk_dir.glob("*.gbk"))

    with open(rast_ids_path, "w") as ids_file:
        for idx, gbk_file in enumerate(gbk_files, start=1):
            rast_id = format_rast_id(idx)
            ids_file.write(f"{rast_id}\t666666.{rast_id}\t{gbk_file.name}\n")
            print(f"Processing {gbk_file.name} as RAST ID 666666.{rast_id}")
            parse_gbk(gbk_file, rast_id, output_dir)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python convert_gbk_to_corason.py <directorio_gbks> <directorio_salida>")
        print("Author: https://github.com/pyrosilesl97")
        sys.exit(1)

    gbk_dir = sys.argv[1]
    output_dir = sys.argv[2]
    main(gbk_dir, output_dir)
