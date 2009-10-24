#! /usr/bin/perl


# Variables Globales.
@PAISES = ("A", "C");
@ESTADOS = ("SANO", "DUDOSO");
@LINEAS_PPI;
# El porcentaje de registros del PPI que se utilizan para generar los contratos.
$PCT_PPI = 0.666;
# el porcentaje de registros de contratos que tienen en mismo monto que el de 
# PPI.
$PCT_MISMO_MONTO = 0.5;

sub randInt {
  return int(rand() * $_[0]);
}

sub generarContratos {
  
  my $pais = $_[0];
  
  open(PPI, "PPI.mae") || die "No se pudo arir PPI.mae";
  open(CONTRATOS, ">CONTRAT.$pais") || die "No se pudo arir CONTRAT.$pais";
  
  while (my $lineaPpi = <PPI>) {
    
    chomp($lineaPpi);
    my @regPpi = split("-", $lineaPpi);
    
    my $suerte = rand() < $PCT_PPI;
    
    # Procesa solo los registros del mismo pais.
    if ($regPpi[0] eq $pais && $suerte) {
      
      my ($sis_id, $anio_id, $mes_id, $no_contrat, $dt_flux) = 
          @regPpi[1, 2, 3, 7, 8];
      my $estado = $ESTADOS[&randInt($#ESTADOS + 1)];
      my ($mt_crd, $mt_impago, $mt_inde, $mt_innode, $mt_otrsumdc, 
          $mt_restante);
      
      my $mismoMonto = rand() < $PCT_MISMO_MONTO;
      
      if ($mismoMonto) {
        ($mt_crd, $mt_impago, $mt_inde, $mt_innode, $mt_otrsumdc) = 
            @regPpi[10, 11, 13, 12, 14];
        # Calculo de monto.
        $mt_restante = $mt_crd + $mt_impago + $mt_inde - $mt_otrsumdc;
      }
      else { 
        ($mt_crd, $mt_impago, $mt_inde, $mt_innode, $mt_otrsumdc) = 
            (0, 0, 0, 0, 0);
        $mt_restante = &randInt(1000) + 1;
      }
      my $dt_insert = (&randInt(12) + 1)."/".(&randInt(31) + 1)."/".
                      (&randInt(9) + 2000);
      #TODO
      my $us_id = 0;
      
      my $linea = join("-", $sis_id, $anio_id, $mes_id, $no_contrat, $dt_flux, 
                       $estado, $mt_crd, $mt_impago, $mt_inde, $mt_innode, 
                       $mt_otrsumdc, $mt_restante, $dt_insert, $us_id);
      print CONTRATOS "$linea\n";
    }
  }
  close(PPI);
  close(CONTRATOS);
}


# Bloque principal.
foreach my $pais (@PAISES) {
  &generarContratos($pais);
}
