package in.gov.moes.ncpor.polarops.dto;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CargoMapper {
    CargoMapper INSTANCE = Mappers.getMapper(CargoMapper.class);

    CargoDto toDto(CargoPackage cargoPackage);
    CargoPackage toEntity(CargoDto cargoDto);
    
    List<CargoDto> toDtoList(List<CargoPackage> cargoPackages);
    
    @org.mapstruct.Mapping(source = "cargo.id", target = "cargoId")
    CargoTrackingEventDto toTrackingDto(in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent event);
    
    List<CargoTrackingEventDto> toTrackingDtoList(List<in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent> events);
}
