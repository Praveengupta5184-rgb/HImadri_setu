package in.gov.moes.ncpor.polarops.client;

import in.gov.moes.ncpor.polarops.dto.DamageDetectionResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
@Slf4j
public class DamageDetectionClient {

    private final RestTemplate restTemplate;

    @Value("${ai.damage.url}")
    private String aiDamageUrl;

    public DamageDetectionResponse detectDamage(String imageUrl) {
        try {
            // In a real scenario, this would send the image file or base64.
            // For now, we simulate the request body.
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            String requestJson = "{\"image_url\":\"" + imageUrl + "\"}";
            HttpEntity<String> request = new HttpEntity<>(requestJson, headers);

            ResponseEntity<DamageDetectionResponse> response = restTemplate.postForEntity(
                    aiDamageUrl + "/detect",
                    request,
                    DamageDetectionResponse.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }
        } catch (Exception e) {
            log.error("Error communicating with AI Damage Detection Service: {}", e.getMessage());
        }
        return null;
    }
}
