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
}
