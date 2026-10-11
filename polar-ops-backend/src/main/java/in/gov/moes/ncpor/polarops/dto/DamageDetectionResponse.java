package in.gov.moes.ncpor.polarops.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DamageDetectionResponse {
    private Boolean isDamaged;
    private String damageType;
    private Double confidence;
    private String recommendation;
    private String aiMode;
    private String modelVersion;
}
