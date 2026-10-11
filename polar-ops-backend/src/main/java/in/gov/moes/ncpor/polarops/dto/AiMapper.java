package in.gov.moes.ncpor.polarops.dto;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface AiMapper {
    AiRecommendationDto toDto(AIRecommendation entity);
    List<AiRecommendationDto> toDtoList(List<AIRecommendation> entities);
    
    AIRecommendation toEntity(AiRecommendationDto dto);
}
