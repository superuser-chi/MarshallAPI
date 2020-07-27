﻿using AutoMapper;
using MarshallAPI.DTO;
using MarshallAPI.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TransportRequisitionSolution.Services.Helpers
{
    public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            CreateMap<Slot, SlotDTO>()
                .ForMember(dest => dest.OwnerName, opts => opts.MapFrom(src => $"{src.kombi.User.Firstname} {src.kombi.User.Firstname}"))
                .ForMember(dest => dest.KombiPlate, opts => opts.MapFrom(src => $"{src.kombi.Plate}"))
                .ForMember(dest => dest.RouteName, opts => opts.MapFrom(src => $"{src.Route.From} to {src.Route.To}"));
        }
    }
}
