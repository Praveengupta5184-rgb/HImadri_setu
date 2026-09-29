package in.gov.moes.ncpor.polarops.dto;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-09-27T02:24:14+0530",
    comments = "version: 1.5.5.Final, compiler: Eclipse JDT (IDE) 3.46.100.v20260826-1225, environment: Java 21.0.12.1 (Eclipse Adoptium)"
)
@Component
public class CargoMapperImpl implements CargoMapper {

    @Override
    public CargoDto toDto(CargoPackage cargoPackage) {
        if ( cargoPackage == null ) {
            return null;
        }

        CargoDto cargoDto = new CargoDto();

        cargoDto.setCargoId( cargoPackage.getCargoId() );
        cargoDto.setCategory( cargoPackage.getCategory() );
        cargoDto.setCreatedAt( cargoPackage.getCreatedAt() );
        cargoDto.setCurrentStatus( cargoPackage.getCurrentStatus() );
        cargoDto.setDestination( cargoPackage.getDestination() );
        cargoDto.setDimensions( cargoPackage.getDimensions() );
        cargoDto.setExpectedDeliveryDate( cargoPackage.getExpectedDeliveryDate() );
        cargoDto.setExpeditionId( cargoPackage.getExpeditionId() );
        cargoDto.setHazardousStatus( cargoPackage.getHazardousStatus() );
        cargoDto.setId( cargoPackage.getId() );
        cargoDto.setOwnerOrganization( cargoPackage.getOwnerOrganization() );
        cargoDto.setPackageNumber( cargoPackage.getPackageNumber() );
        cargoDto.setProjectName( cargoPackage.getProjectName() );
        cargoDto.setRiskScore( cargoPackage.getRiskScore() );
        cargoDto.setStorageConditions( cargoPackage.getStorageConditions() );
        cargoDto.setTotalPackages( cargoPackage.getTotalPackages() );
        cargoDto.setWeight( cargoPackage.getWeight() );

        return cargoDto;
    }

    @Override
    public CargoPackage toEntity(CargoDto cargoDto) {
        if ( cargoDto == null ) {
            return null;
        }

        CargoPackage.CargoPackageBuilder cargoPackage = CargoPackage.builder();

        cargoPackage.cargoId( cargoDto.getCargoId() );
        cargoPackage.category( cargoDto.getCategory() );
        cargoPackage.createdAt( cargoDto.getCreatedAt() );
        cargoPackage.currentStatus( cargoDto.getCurrentStatus() );
        cargoPackage.destination( cargoDto.getDestination() );
        cargoPackage.dimensions( cargoDto.getDimensions() );
        cargoPackage.expectedDeliveryDate( cargoDto.getExpectedDeliveryDate() );
        cargoPackage.expeditionId( cargoDto.getExpeditionId() );
        cargoPackage.hazardousStatus( cargoDto.getHazardousStatus() );
        cargoPackage.id( cargoDto.getId() );
        cargoPackage.ownerOrganization( cargoDto.getOwnerOrganization() );
        cargoPackage.packageNumber( cargoDto.getPackageNumber() );
        cargoPackage.projectName( cargoDto.getProjectName() );
        cargoPackage.riskScore( cargoDto.getRiskScore() );
        cargoPackage.storageConditions( cargoDto.getStorageConditions() );
        cargoPackage.totalPackages( cargoDto.getTotalPackages() );
        cargoPackage.weight( cargoDto.getWeight() );

        return cargoPackage.build();
    }

    @Override
    public List<CargoDto> toDtoList(List<CargoPackage> cargoPackages) {
        if ( cargoPackages == null ) {
            return null;
        }

        List<CargoDto> list = new ArrayList<CargoDto>( cargoPackages.size() );
        for ( CargoPackage cargoPackage : cargoPackages ) {
            list.add( toDto( cargoPackage ) );
        }

        return list;
    }
}
